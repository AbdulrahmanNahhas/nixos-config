_: {
  programs.zed-editor.userSettings = {
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
      light = "Carbonfox - blurred";
      dark = "Rich Vesper";
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
    auto_indent = true;
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
      show_other_hints = true;
      show_parameter_hints = true;
      show_type_hints = true;
      show_background = false;
    };

    snippet_sort_order = "inline";
    unnecessary_code_fade = 0.5;
    enable_language_server = true;

    diagnostics = {
      inline = {
        enabled = true;
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
      hide_gitignore = true;
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
      sidebar_side = "right";
      default_profile = "ask";
      default_model = {
        provider = "zed.dev";
        model = "claude-sonnet-4-5";
      };
    };
    show_edit_predictions = true;
    edit_predictions = {
      provider = "zed";
      disabled_globs = [ ];
    };

    # ── Tasks ────────────────────────────────────────────
    tasks = {
      prefer_lsp = true;
    };
  };
}
