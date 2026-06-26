# Zed editor configuration
{ pkgs, ... }:

{
  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor.fhs;

    # Extensions to auto-install on first run.
    extensions = [
      "nix"
      "toml"
      "vercel-theme"
      "rainbow-csv"
      "comment"
      "charmed-icons"
    ];

    userSettings = {
      # ── Privacy ──────────────────────────────────────────
      language_models.opencode.show_zen_models = false;
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
        anthropic_retention = false;
      };
      code_lens = "on";
      diff_view_style = "unified";
      use_on_type_format = false;
      use_system_path_prompts = true;

      # ── Theme / appearance ───────────────────────────────
      theme = {
        mode = "dark";
        light = "Vercel Light";
        dark = "Vercel Dark";
      };
      theme_overrides = {
        "Vercel Light" = {
          syntax.hint.color = "#5c6370";
        };
        "Vercel Dark" = {
          syntax.hint.color = "#5c6370";
        };
        "Rust & Brown" = {
          syntax.hint.color = "#514e48";
        };
      };
      icon_theme = {
        mode = "dark";
        light = "Warm Charmed Icons";
        dark = "Warm Charmed Icons";
      };

      # ── Font / typography ────────────────────────────────
      ui_font_family = "Zed Plex Sans";
      buffer_font_family = "Zed Plex Mono";
      ui_font_size = 18;
      buffer_font_size = 18;
      buffer_font_weight = 400.0;
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

      search.whole_word = false;

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
        show_value_hints = true;
        show_other_hints = true;
        show_parameter_hints = true;
        show_type_hints = true;
        show_background = false;
      };

      snippet_sort_order = "inline";
      unnecessary_code_fade = 0.5;
      inline_code_actions = true;
      enable_language_server = true;

      diagnostics.inline = {
        min_column = 0;
        padding = 4;
      };

      sticky_scroll.enabled = true;

      # ── UI panels ────────────────────────────────────────
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
        sort_by_path = false;
        dock = "right";
        tree_view = true;
      };
      collaboration_panel.dock = "right";
      outline_panel.dock = "left";
      debugger.dock = "left";
      minimap = {
        show = "never";
        max_width_columns = 50;
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
        font_size = 14.0;
        font_family = "GeistMono Nerd Font";
        toolbar.breadcrumbs = true;
        # was /opt/homebrew/bin/fish on macOS
        shell.program = "fish";
        env.TERM_PROGRAM = "zed";
      };

      # ── Git / calls / audio ──────────────────────────────
      git.blame.show_avatar = true;
      calls = {
        mute_on_join = true;
        share_on_join = false;
      };
      audio."experimental.auto_microphone_volume" = true;

      # ── AI / agents ──────────────────────────────────────
      disable_ai = false;
      agent_servers = { };
      agent = {
        favorite_models = [
          {
            provider = "opencode";
            model = "go/glm-5.2";
            enable_thinking = true;
            effort = "xhigh";
          }
          {
            provider = "opencode";
            model = "go/deepseek-v4-pro";
            enable_thinking = true;
            effort = "medium";
          }
          {
            provider = "opencode";
            model = "go/deepseek-v4-flash";
            enable_thinking = false;
            effort = "low";
          }
          {
            provider = "opencode";
            model = "go/glm-5.1";
            enable_thinking = false;
          }
          {
            provider = "opencode";
            model = "go/qwen3.7-max";
            enable_thinking = false;
          }
        ];
        sidebar_side = "right";
        dock = "right";
        flexible = false;
        play_sound_when_agent_done = "always";
        single_file_review = true;
        default_profile = "ask";
        default_model = {
          effort = "low";
          provider = "opencode";
          model = "go/deepseek-v4-flash";
          enable_thinking = false;
        };
      };
      show_edit_predictions = true;
      edit_predictions = {
        codestral.api_url = "https://codestral.mistral.ai";
        disabled_globs = [ ];
        provider = "zed";
      };

      # ── Tasks ────────────────────────────────────────────
      tasks = {
        prefer_lsp = true;
        enabled = true;
      };

      # ── Language settings ─────────────────────────────────
      languages = {
        Nix = {
          language_servers = [ "nixd" ];
          formatter = [ { language_server.name = "nixfmt"; } ];
          format_on_save = "on";
        };
        Rust = {
          tab_size = 2;
          formatter = "language_server";
          format_on_save = "on";
        };
        C = {
          language_servers = [ "clangd" ];
          formatter = "language_server";
          format_on_save = "on";
        };
        "C++" = {
          language_servers = [ "clangd" ];
          formatter = "language_server";
          format_on_save = "on";
        };
        CSS = {
          format_on_save = "on";
          prettier.allowed = false;
          formatter = [ { language_server.name = "oxfmt"; } ];
        };
        HTML = {
          format_on_save = "on";
          prettier.allowed = false;
          formatter = [ { language_server.name = "oxfmt"; } ];
        };
        JavaScript = {
          format_on_save = "on";
          prettier.allowed = false;
          formatter = [
            { language_server.name = "oxfmt"; }
            { code_action = "source.fixAll.oxc"; }
          ];
        };
        TypeScript = {
          format_on_save = "on";
          prettier.allowed = false;
          formatter = [ { language_server.name = "oxfmt"; } ];
        };
        TSX = {
          format_on_save = "on";
          prettier.allowed = false;
          formatter = [ { language_server.name = "oxfmt"; } ];
        };
        JSON = {
          format_on_save = "on";
          prettier.allowed = false;
          formatter = [ { language_server.name = "oxfmt"; } ];
        };
        JSONC = {
          format_on_save = "on";
          prettier.allowed = false;
          formatter = [ { language_server.name = "oxfmt"; } ];
        };
        Markdown = {
          format_on_save = "on";
          prettier.allowed = false;
          formatter = [ { language_server.name = "oxfmt"; } ];
        };
        YAML = {
          format_on_save = "on";
          prettier.allowed = false;
          formatter = [ { language_server.name = "oxfmt"; } ];
        };
      };

      # ── Language servers ──────────────────────────────────
      lsp = {
        oxfmt.initialization_options.settings = {
          "fmt.configPath" = null;
          run = "onSave";
        };

        vtsls = {
          enable_lsp_tasks = true;
          settings = {
            typescript = {
              updateImportsOnFileMove.enabled = "always";
              preferences = {
                includeInlayParameterNameHints = "none";
                includeInlayParameterNameHintsWhenArgumentMatchesName = false;
                includeInlayFunctionParameterTypeHints = false;
                includeInlayVariableTypeHints = false;
                includeInlayVariableTypeHintsWhenTypeMatchesName = false;
                includeInlayPropertyDeclarationTypeHints = false;
                includeInlayFunctionLikeReturnTypeHints = false;
                includeInlayEnumMemberValueHints = false;
              };
            };
            javascript = {
              updateImportsOnFileMove.enabled = "always";
              preferences = {
                includeInlayParameterNameHints = "none";
                includeInlayParameterNameHintsWhenArgumentMatchesName = false;
                includeInlayFunctionParameterTypeHints = false;
                includeInlayVariableTypeHints = false;
                includeInlayVariableTypeHintsWhenTypeMatchesName = false;
                includeInlayPropertyDeclarationTypeHints = false;
                includeInlayFunctionLikeReturnTypeHints = false;
                includeInlayEnumMemberValueHints = false;
              };
            };
          };
        };

        rust-analyzer = {
          enable_lsp_tasks = true;
          initialization_options = {
            check.onSave = true;
            inlayHints = {
              maxLength = null;
              lifetimeElisionHints = {
                enable = "skip_trivial";
                useParameterNames = true;
              };
              closureReturnTypeHints.enable = "always";
              bindingModeHints.enable = true;
              discriminantHints.enable = "fieldless";
              closingBraceHints = {
                enable = true;
                minLines = 1;
              };
            };
            lens = {
              enable = true;
              implementations.enable = true;
              references = {
                adt.enable = false;
                enumVariant.enable = false;
                method.enable = false;
                trait.enable = false;
              };
              run.enable = true;
              debug.enable = true;
            };
          };
        };

        clangd.initialization_options.fallbackFlags = [ "-std=c++20" ];
      };
    };
  };
}
