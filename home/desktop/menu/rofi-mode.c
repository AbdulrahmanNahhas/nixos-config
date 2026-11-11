#define _POSIX_C_SOURCE 200809L
#include <pango/pangocairo.h>
#include <rofi/mode-private.h>
#include <rofi/rofi-icon-fetcher.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
  char *kind, *display, *search, *label, *icon;
  cairo_surface_t *surface;
  unsigned int icon_size;
  uint32_t icon_uid;
} Row;

typedef struct {
  GPtrArray *rows;
  char **words;
  gboolean root, empty;
  guint navigation_count, watch;
  unsigned int selected;
} State;

static void paint_icon(Row *row, gboolean selected);

// Rofi exports these view helpers for native modes but does not install view.h.
extern void *rofi_view_get_active(void);
extern const char *rofi_view_get_user_input(const void *view);
extern void rofi_view_reload(void);

static gboolean watch_input(gpointer data) {
  State *state = data;
  const void *view = rofi_view_get_active();
  if (!view)
    return G_SOURCE_CONTINUE;
  const char *input = rofi_view_get_user_input(view);
  char *query = g_strdup(input ? input : "");
  gboolean empty = *g_strstrip(query) == '\0';
  g_free(query);
  // Rofi skips matching callbacks when the entry is cleared. Refresh only when
  // crossing that boundary; this watch exists solely while the menu is open.
  if (empty != state->empty) {
    state->empty = empty;
    rofi_view_reload();
  }
  return G_SOURCE_CONTINUE;
}

static void free_row(gpointer data) {
  Row *row = data;
  g_free(row->kind);
  g_free(row->display);
  g_free(row->search);
  g_free(row->label);
  g_free(row->icon);
  if (row->surface)
    cairo_surface_destroy(row->surface);
  g_free(row);
}

static char *decode(const char *encoded) {
  gsize length;
  guchar *bytes = g_base64_decode(encoded, &length);
  char *text = g_strndup((char *)bytes, length);
  g_free(bytes);
  return text;
}

static int init(Mode *mode) {
  State *state = g_new0(State, 1);
  state->rows = g_ptr_array_new_with_free_func(free_row);
  state->root = g_strcmp0(g_getenv("SHADOW_MENU_ROOT"), "1") == 0;
  state->empty = TRUE;
  state->selected = G_MAXUINT;
  mode->private_data = state;
  mode->display_name = (char *)g_getenv("SHADOW_MENU_TITLE");
  char *line = NULL;
  size_t capacity = 0;
  while (getline(&line, &capacity, stdin) != -1) {
    g_strchomp(line);
    gchar **fields = g_strsplit(line, "\t", -1);
    if (g_strv_length(fields) != 5) {
      g_printerr("shadow menu: invalid row protocol\n");
      g_strfreev(fields);
      free(line);
      return FALSE;
    }
    Row *row = g_new0(Row, 1);
    row->kind = g_strdup(fields[0]);
    if (strcmp(row->kind, "nav") == 0)
      state->navigation_count++;
    row->display = decode(fields[1]);
    row->search = decode(fields[2]);
    row->label = decode(fields[3]);
    row->icon = decode(fields[4]);
    g_ptr_array_add(state->rows, row);
    g_strfreev(fields);
  }
  free(line);
  if (state->root)
    state->watch = g_timeout_add(50, watch_input, state);
  return state->rows->len > 0;
}

static void destroy(Mode *mode) {
  State *state = mode->private_data;
  if (!state)
    return;
  if (state->watch)
    g_source_remove(state->watch);
  g_ptr_array_free(state->rows, TRUE);
  g_strfreev(state->words);
  g_free(state);
  mode->private_data = NULL;
}

static unsigned int count(const Mode *mode) {
  const State *state = mode->private_data;
  return state->root && state->empty ? state->navigation_count
                                     : state->rows->len;
}

static char *preprocess(Mode *mode, const char *input) {
  State *state = mode->private_data;
  char *query = g_utf8_casefold(input ? input : "", -1);
  g_strstrip(query);
  gboolean empty = *query == '\0';
  if (empty != state->empty) {
    state->empty = empty;
    rofi_view_reload();
  }
  g_strfreev(state->words);
  state->words = g_strsplit_set(query, " \t\r\n", -1);
  g_free(query);
  return g_strdup(input ? input : "");
}

static int match(const Mode *mode, rofi_int_matcher **tokens G_GNUC_UNUSED,
                 unsigned int index) {
  const State *state = mode->private_data;
  const Row *row = g_ptr_array_index(state->rows, index);
  if (state->empty)
    return !state->root || strcmp(row->kind, "nav") == 0;
  if (strcmp(row->kind, "back") == 0)
    return FALSE;
  // Root categories stay navigation; typed queries search the complete action
  // catalog.
  if (state->root && strcmp(row->kind, "nav") == 0)
    return FALSE;
  char *search = g_utf8_casefold(row->search, -1);
  gboolean found = TRUE;
  for (char **word = state->words; word && *word; word++) {
    if (**word && !strstr(search, *word)) {
      found = FALSE;
      break;
    }
  }
  g_free(search);
  return found;
}

static char *display(const Mode *mode, unsigned int index, int *flags,
                     GList **attributes G_GNUC_UNUSED, int get_entry) {
  State *state = mode->private_data;
  const Row *row = g_ptr_array_index(state->rows, index);
  // The current-entry widget is notified on every keyboard/mouse selection
  // change.
  if (get_entry && attributes == NULL && state->selected != index) {
    if (state->selected < state->rows->len)
      paint_icon(g_ptr_array_index(state->rows, state->selected), FALSE);
    state->selected = index;
    paint_icon(g_ptr_array_index(state->rows, index), TRUE);
  }
  // MARKUP is part of Rofi's row-state ABI, but its enum is not installed
  // publicly.
  *flags |= 8;
  return get_entry ? g_strdup(row->display) : NULL;
}

static char *completion(const Mode *mode, unsigned int index) {
  const State *state = mode->private_data;
  const Row *row = g_ptr_array_index(state->rows, index);
  return g_strdup(row->label);
}

static void paint_icon(Row *row, gboolean selected) {
  if (!row->surface)
    return;
  unsigned int height = row->icon_size;
  cairo_t *cr = cairo_create(row->surface);
  // Render above the logical size so HiDPI outputs never upscale a small
  // bitmap.
  cairo_scale(cr, 4.0, 4.0);
  cairo_set_operator(cr, CAIRO_OPERATOR_CLEAR);
  cairo_paint(cr);
  cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
  PangoLayout *layout = pango_cairo_create_layout(cr);
  PangoFontDescription *font =
      pango_font_description_from_string("GeistMono Nerd Font");
  pango_font_description_set_absolute_size(font, height * 0.85 * PANGO_SCALE);
  pango_layout_set_font_description(layout, font);
  pango_layout_set_text(layout, row->icon, -1);
  PangoRectangle bounds;
  pango_layout_get_pixel_extents(layout, &bounds, NULL);
  unsigned int r = 216, g = 222, b = 233;
  const char *color = g_getenv(selected ? "SHADOW_MENU_SELECTED_ICON_COLOR"
                                        : "SHADOW_MENU_ICON_COLOR");
  if (selected) {
    r = 22;
    g = 22;
    b = 30;
  }
  if (color)
    sscanf(color, "#%2x%2x%2x", &r, &g, &b);
  cairo_set_source_rgb(cr, r / 255.0, g / 255.0, b / 255.0);
  cairo_move_to(cr, ((double)height - bounds.width) / 2.0 - bounds.x,
                ((double)height - bounds.height) / 2.0 - bounds.y);
  pango_cairo_show_layout(cr, layout);
  pango_font_description_free(font);
  g_object_unref(layout);
  cairo_destroy(cr);
  cairo_surface_mark_dirty(row->surface);
}

static cairo_surface_t *icon(const Mode *mode, unsigned int index,
                             unsigned int height) {
  const State *state = mode->private_data;
  Row *row = g_ptr_array_index(state->rows, index);
  if (!row->icon || !*row->icon || height == 0)
    return NULL;
  if (g_str_has_prefix(row->icon, "theme:")) {
    if (!row->icon_uid || row->icon_size != height) {
      row->icon_size = height;
      row->icon_uid = rofi_icon_fetcher_query(row->icon + 6, height * 4);
    }
    return rofi_icon_fetcher_get(row->icon_uid);
  }
  if (row->surface && row->icon_size == height)
    return row->surface;
  if (row->surface)
    cairo_surface_destroy(row->surface);
  row->icon_size = height;
  row->surface =
      cairo_image_surface_create(CAIRO_FORMAT_ARGB32, height * 4, height * 4);
  paint_icon(row, state->selected == index);
  return row->surface;
}

static char *message(const Mode *mode G_GNUC_UNUSED) {
  return g_strdup(g_getenv("SHADOW_MENU_FOOTER"));
}

static ModeMode result(Mode *mode, int event, char **input G_GNUC_UNUSED,
                       unsigned int index) {
  if (event & MENU_CUSTOM_COMMAND)
    printf("key:%d\n", event & MENU_LOWER_MASK);
  else if ((event & MENU_OK) && index < count(mode))
    printf("%u\n", index);
  return MODE_EXIT;
}

G_MODULE_EXPORT Mode mode = {
    .abi_version = ABI_VERSION,
    .name = "shadow-menu",
    ._init = init,
    ._destroy = destroy,
    ._get_num_entries = count,
    ._get_display_value = display,
    ._get_completion = completion,
    ._get_icon = icon,
    ._preprocess_input = preprocess,
    ._token_match = match,
    ._get_message = message,
    ._result = result,
};

#ifdef SHADOW_MODE_TEST
uint32_t rofi_icon_fetcher_query(const char *name G_GNUC_UNUSED,
                                 const int size G_GNUC_UNUSED) {
  return 0;
}
cairo_surface_t *rofi_icon_fetcher_get(const uint32_t uid G_GNUC_UNUSED) {
  return NULL;
}
void *rofi_view_get_active(void) { return NULL; }
const char *rofi_view_get_user_input(const void *view G_GNUC_UNUSED) {
  return "";
}
void rofi_view_reload(void) {}
int main(void) {
  State state = {
      .rows = g_ptr_array_new(), .root = TRUE, .navigation_count = 1};
  Row nav = {.kind = "nav", .search = "NixOS"};
  Row back = {.kind = "back", .search = "Back"};
  Row test = {.kind = "action", .search = "Test temporarily nix NixOS"};
  Row check = {.kind = "action", .search = "Check configuration nix NixOS"};
  g_ptr_array_add(state.rows, &nav);
  g_ptr_array_add(state.rows, &back);
  g_ptr_array_add(state.rows, &test);
  g_ptr_array_add(state.rows, &check);
  Mode test_mode = {.private_data = &state};
  const char *queries[] = {"", "test", "NIXOS test", "tset", "  ", NULL};
  const int expected[][4] = {
      {1, 0, 0, 0}, {0, 0, 1, 0}, {0, 0, 1, 0}, {0, 0, 0, 0}, {1, 0, 0, 0}};
  for (int q = 0; queries[q]; q++) {
    g_free(preprocess(&test_mode, queries[q]));
    g_assert_cmpuint(count(&test_mode), ==, state.empty ? 1 : 4);
    for (unsigned int i = 0; i < 4; i++)
      g_assert_cmpint(match(&test_mode, NULL, i), ==, expected[q][i]);
  }
  state.root = FALSE;
  g_free(preprocess(&test_mode, ""));
  for (unsigned int i = 0; i < 4; i++)
    g_assert_true(match(&test_mode, NULL, i));
  int flags = 0;
  g_free(display(&test_mode, 2, &flags, NULL, TRUE));
  g_assert_cmpuint(state.selected, ==, 2);
  g_free(display(&test_mode, 3, &flags, NULL, TRUE));
  g_assert_cmpuint(state.selected, ==, 3);
  g_strfreev(state.words);
  g_ptr_array_free(state.rows, TRUE);
  puts("PASS: root visibility, global search, exact token matching, case "
       "folding, multiword search and query clearing");
  return 0;
}
#endif
