{ lib, ... }:
let
  extensions = import ./extensions.nix;
  chatgptModel = {
    provider = "openai-subscribed";
    model = "gpt-6.1-sol";
    effort = "medium";
  };
in
{
  programs.zed-editor.userSettings = {
    auto_install_extensions = lib.genAttrs extensions (_: true) // {
      # Override the old value retained by mutable Home Manager settings.
      biome = false;
    };

    # ── Privacy ──────────────────────────────────────────
    redact_private_values = false;
    private_files = [
      "**/.env*"
      "**/*.pem"
      "**/*.key"
      "**/*.cert"
      "**/*.crt"
      "**/secrets.yml"
    ];

    # ── Core behavior ────────────────────────────────────
    cli_default_open_behavior = "new_window";
    # Nix owns the editor binary; Zed manages its extensions separately.
    auto_update = false;
    confirm_quit = true;
    base_keymap = "VSCode";
    vim_mode = false;
    helix_mode = false;
    telemetry = {
      diagnostics = false;
      metrics = false;
    };
    code_lens = "on";
    diff_view_style = "unified";
    use_on_type_format = false;
    # direnv integration: "direct" works with any shell (fish included),
    # doesn't require the shell hook to have fired. Good default for HM setups.
    load_direnv = "direct";

    # ── Theme / appearance ───────────────────────────────
    theme = {
      mode = "dark";
      light = "Rust & Brown";
      dark = "Vercel Dark";
    };
    theme_overrides = {
      "Rich Vesper" = {
        "background" = "#101010E0";
        "surface.background" = "#101010E8";
        "elevated_surface.background" = "#1A1A1AED";

        "element.background" = "#101010D9";
        "element.hover" = "#282828E0";
        "element.active" = "#282828E8";
        "element.selected" = "#232323E8";
        "element.disabled" = "#101010CC";

        "ghost_element.hover" = "#282828CC";
        "ghost_element.selected" = "#232323CC";

        "status_bar.background" = "#101010E0";
        "title_bar.background" = "#101010E0";
        "toolbar.background" = "#101010E0";

        "tab_bar.background" = "#101010D9";
        "tab.inactive_background" = "#101010D1";
        "tab.active_background" = "#161616E8";

        "panel.background" = "#101010E0";

        "scrollbar.track.background" = "#1010108C";
        "scrollbar.track.border" = "#101010CC";

        "editor.background" = "#10101091";
        "editor.gutter.background" = "#101010A3";
        "editor.subheader.background" = "#101010CC";
        "editor.active_line.background" = "#19191999";
        "editor.highlighted_line.background" = "#1010107A";

        "terminal.background" = "#0D0D0D80";
      };
      "Vercel Light" = {
        syntax = {
          hint = {
            color = "#5c6370";
          };
        };
      };
      "Vercel Dark" = {
        syntax = {
          hint = {
            color = "#5c6370";
          };
        };
      };
    };
    icon_theme = {
      mode = "dark";
      light = "Warm Charmed Icons";
      dark = "Warm Charmed Icons";
    };

    # ── Font / typography ────────────────────────────────
    ui_font_family = "GeistMono Nerd Font Propo";
    buffer_font_family = "GeistMono Nerd Font Propo";
    ui_font_size = 18;
    buffer_font_size = 18;
    buffer_font_weight = 400;
    buffer_line_height = "comfortable";
    buffer_font_features = {
      calt = true;
      liga = true;
    };

    # ── Editor behavior ──────────────────────────────────
    autosave = "on_focus_change";
    format_on_save = "on";
    hover_popover_enabled = true;
    use_autoclose = true;
    auto_indent = "syntax_aware";
    auto_indent_on_paste = true;
    preferred_line_length = 100;
    soft_wrap = "prefer_line";
    scroll_sensitivity = 1.0;
    cursor_blink = false;
    cursor_shape = "block";
    hide_mouse = "on_typing_and_action";
    selection_highlight = true;
    rounded_selection = true;
    linked_edits = true;
    remove_trailing_whitespace_on_save = true;
    ensure_final_newline_on_save = true;

    search = {
      whole_word = false;
    };

    indent_guides = {
      enabled = true;
      coloring = "indent_aware";
      background_coloring = "disabled";
      active_line_width = 1;
    };

    inlay_hints = {
      enabled = true;
      scroll_debounce_ms = 50;
      edit_debounce_ms = 700;
      show_other_hints = false;
      show_parameter_hints = false;
      show_type_hints = true;
      show_background = false;
    };

    snippet_sort_order = "inline";
    unnecessary_code_fade = 0.5;
    enable_language_server = true;
    # Projects can explicitly select a different toolchain when needed.
    language_servers = [
      "!biome"
      "!eslint"
      "!typescript-language-server"
      "..."
    ];

    diagnostics = {
      inline = {
        enabled = true;
        update_debounce_ms = 300;
        min_column = 0;
        padding = 4;
      };
    };

    # ── UI panels ────────────────────────────────────────
    bottom_dock_layout = "full";
    resize_all_panels_in_dock = [
      "left"
      "right"
      "bottom"
    ];
    tabs = {
      show_diagnostics = "all";
      close_position = "left";
      file_icons = true;
      git_status = true;
    };
    project_panel = {
      dock = "left";
      hide_gitignore = false;
      hide_hidden = false;
    };
    git_panel = {
      dock = "right";
    };
    collaboration_panel = {
      dock = "right";
    };
    outline_panel = {
      dock = "right";
    };
    debugger = {
      dock = "bottom";
    };
    minimap = {
      show = "never";
    };
    toolbar = {
      code_actions = false;
      selections_menu = true;
      quick_actions = true;
      breadcrumbs = true;
    };
    gutter = {
      line_numbers = true;
      min_line_number_digits = 2;
      breakpoints = true;
      folds = true;
      runnables = true;
    };

    # ── Terminal ─────────────────────────────────────────
    terminal = {
      dock = "bottom";
      font_size = 18;
      font_family = "GeistMono Nerd Font Propo";
      shell = {
        program = "fish";
      };
      env = {
        TERM_PROGRAM = "zed";
      };
    };

    # ── Git ──────────────────────────────────────────────
    git = {
      inline_blame = {
        enabled = true;
        delay_ms = 800;
      };
    };
    calls = {
      mute_on_join = true;
      share_on_join = false;
    };

    # ── AI / Agent ────────────────────────────────────────
    disable_ai = false;
    agent = {
      dock = "left";
      threads_sidebar.position = "right";
      default_profile = "ask";
      default_model = chatgptModel;
      # Override previously selected API models retained in mutable settings.
      inline_assistant_model = chatgptModel;
      commit_message_model = chatgptModel;
      thread_summary_model = chatgptModel;
      auto_compact = {
        enabled = true;
        threshold = "90%";
      };
      show_turn_stats = true;
      # Shadow's desktop portal rejects the idle inhibition request. Let
      # the desktop's existing power policy govern sleep during AI work.
      prevent_idle_sleep = false;
      tool_permissions = {
        tools = {
          fetch = {
            always_allow = [
              { pattern = "^https://oxc\\.rs(?:/|$)"; }
              { pattern = "^https://zed\\.dev(?:/|$)"; }
              { pattern = "^https://ui\\.shadcn\\.com(?:/|$)"; }
              { pattern = "^https://(?:[a-zA-Z0-9-]+\\.)*rust-lang\\.org(?:/|$)"; }
              { pattern = "^https://docs\\.rs(?:/|$)"; }
              { pattern = "^https://crates\\.io(?:/|$)"; }
              { pattern = "^https://(?:[a-zA-Z0-9-]+\\.)*nixos\\.org(?:/|$)"; }
              { pattern = "^https://noogle\\.dev(?:/|$)"; }
              { pattern = "^https://developer\\.mozilla\\.org(?:/|$)"; }
              { pattern = "^https://(?:[a-zA-Z0-9-]+\\.)*typescriptlang\\.org(?:/|$)"; }
              { pattern = "^https://(?:www\\.)?npmjs\\.com(?:/|$)"; }
              { pattern = "^https://en\\.cppreference\\.com(?:/|$)"; }
            ];
          };
        };
      };
      sandbox_permissions = {
        allow_unsandboxed = false;
        network_hosts = [
          "github.com"
          "raw.githubusercontent.com"
          "oxc.rs"
          "zed.dev"
          "gitlab.com"
          "wikipedia.org"
          "docs.rs"
          "crates.io"
          "doc.rust-lang.org"
          "search.nixos.org"
          "noogle.dev"
          "developer.mozilla.org"
          "typescriptlang.org"
          "npmjs.com"
          "registry.npmjs.org"
          "en.cppreference.com"
        ];
      };
    };
    # ChatGPT's provider does not supply Zed edit predictions. The previous
    # Zed prediction provider returned 403 with this account.
    show_edit_predictions = false;
    edit_predictions = {
      provider = "none";
      disabled_globs = [
        "..."
        "**/secrets.yaml"
        "**/.npmrc"
        "**/.netrc"
      ];
    };

    # ── Tasks ────────────────────────────────────────────
    tasks = {
      prefer_lsp = true;
    };
  };
}
