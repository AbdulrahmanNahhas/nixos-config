#include <gio/gdesktopappinfo.h>
#include <stdio.h>
#include <string.h>

// GIO owns desktop-file precedence, visibility, Exec expansion and D-Bus
// launch.
static void field(const char *value, gboolean last) {
  char *encoded = g_base64_encode((const guchar *)(value ? value : ""),
                                  value ? strlen(value) : 0);
  printf("%s%c", encoded, last ? '\n' : '\t');
  g_free(encoded);
}

int main(int argc, char **argv) {
  if (argc == 3 && strcmp(argv[1], "launch") == 0) {
    GDesktopAppInfo *app = g_desktop_app_info_new(argv[2]);
    if (!app) {
      g_printerr("Application is no longer installed\n");
      return 1;
    }
    GError *error = NULL;
    gboolean ok = g_app_info_launch(G_APP_INFO(app), NULL, NULL, &error);
    if (!ok) {
      g_printerr("%s\n", error->message);
      g_error_free(error);
    }
    g_object_unref(app);
    return ok ? 0 : 1;
  }
  if (argc != 2 || strcmp(argv[1], "list") != 0)
    return 2;
  GList *apps = g_app_info_get_all();
  for (GList *item = apps; item; item = item->next) {
    GAppInfo *app = item->data;
    if (!G_IS_DESKTOP_APP_INFO(app) || !g_app_info_should_show(app))
      continue;
    const char *id = g_app_info_get_id(app);
    if (!id)
      continue;
    GDesktopAppInfo *desktop = G_DESKTOP_APP_INFO(app);
    GIcon *icon = g_app_info_get_icon(app);
    char *icon_name = NULL;
    if (G_IS_THEMED_ICON(icon))
      icon_name = g_strdup(g_themed_icon_get_names(G_THEMED_ICON(icon))[0]);
    else if (G_IS_FILE_ICON(icon))
      icon_name = g_file_get_path(g_file_icon_get_file(G_FILE_ICON(icon)));
    const char *const *keywords = g_desktop_app_info_get_keywords(desktop);
    char *words = keywords ? g_strjoinv(" ", (char **)keywords) : g_strdup("");
    field(id, FALSE);
    field(g_app_info_get_display_name(app), FALSE);
    field(g_app_info_get_description(app), FALSE);
    field(icon_name ? icon_name : "application-x-executable", FALSE);
    field(words, TRUE);
    g_free(words);
    g_free(icon_name);
  }
  g_list_free_full(apps, g_object_unref);
  return 0;
}
