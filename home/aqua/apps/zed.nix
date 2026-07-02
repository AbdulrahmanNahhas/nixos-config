{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor.fhs;

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
        light = "Vercel Light";
        dark = "Vercel Dark";
      };
      # theme_overrides take real theme keys (syntax token names), not dotted strings.
      theme_overrides = {
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
        dock = "left";
      };
      debugger = {
        dock = "left";
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

      # ── AI / Agent (current "agent" schema, formerly "assistant") ──
      disable_ai = false;

      # NOTE: opencode is not a `language_models` provider. If you want to use
      # OpenCode's own model routing inside Zed, install it as an External Agent
      # (ACP) via `zed: acp registry` in the command palette, then start threads
      # from the Agent Panel/Threads Sidebar. It manages its own auth/model list.
      #
      # If instead you have an OpenAI-compatible *gateway* that exposes those
      # go/deepseek-v4-flash-style model names, configure it here as a custom
      # openai_compatible provider (fill in the real api_url):
      #
      # language_models = {
      #   openai_compatible = {
      #     "MyGateway" = {
      #       api_url = "https://your-gateway.example.com/v1";
      #       available_models = [
      #         { name = "go/deepseek-v4-flash"; display_name = "DeepSeek V4 Flash"; max_tokens = 128000; }
      #       ];
      #     };
      #   };
      # };

      agent = {
        default_profile = "ask";
        # Set this to whatever model you actually have provider access to.
        # "zed.dev" only works with a Zed subscription; otherwise point it at
        # anthropic / openai / openai_compatible / etc. per LLM Providers docs.
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

      # ── Language settings ─────────────────────────────────
      languages = {
        Nix = {
          formatter = {
            language_server = {
              name = "nixd";
            };
          };
          format_on_save = "on";
        };
        Rust = {
          tab_size = 2;
          formatter = "language_server";
          format_on_save = "on";
        };
        C = {
          formatter = "language_server";
          format_on_save = "on";
        };
        "C++" = {
          formatter = "language_server";
          format_on_save = "on";
        };
        CSS = {
          format_on_save = "on";
          formatter = {
            language_server = {
              name = "oxfmt";
            };
          };
        };
        HTML = {
          format_on_save = "on";
          formatter = {
            language_server = {
              name = "oxfmt";
            };
          };
        };
        JavaScript = {
          format_on_save = "on";
          formatter = {
            language_server = {
              name = "oxfmt";
            };
          };
        };
        TypeScript = {
          format_on_save = "on";
          formatter = {
            language_server = {
              name = "oxfmt";
            };
          };
        };
        TSX = {
          format_on_save = "on";
          formatter = {
            language_server = {
              name = "oxfmt";
            };
          };
        };
        JSON = {
          format_on_save = "on";
          formatter = {
            language_server = {
              name = "oxfmt";
            };
          };
        };
        JSONC = {
          format_on_save = "on";
          formatter = {
            language_server = {
              name = "oxfmt";
            };
          };
        };
        Markdown = {
          format_on_save = "on";
          formatter = {
            language_server = {
              name = "oxfmt";
            };
          };
        };
        YAML = {
          format_on_save = "on";
          formatter = {
            language_server = {
              name = "oxfmt";
            };
          };
        };
      };

      # ── Language servers ──────────────────────────────────
      lsp = {
        vtsls = {
          settings = {
            typescript = {
              updateImportsOnFileMove = {
                enabled = "always";
              };
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
              updateImportsOnFileMove = {
                enabled = "always";
              };
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
            check = {
              command = "clippy";
            };
            inlayHints = {
              maxLength = null;
              lifetimeElisionHints = {
                enable = "skip_trivial";
                useParameterNames = true;
              };
              closureReturnTypeHints = {
                enable = "always";
              };
              bindingModeHints = {
                enable = true;
              };
              discriminantHints = {
                enable = "fieldless";
              };
              closingBraceHints = {
                enable = true;
                minLines = 1;
              };
            };
            lens = {
              enable = true;
              implementations = {
                enable = true;
              };
              references = {
                adt = {
                  enable = false;
                };
                enumVariant = {
                  enable = false;
                };
                method = {
                  enable = false;
                };
                trait = {
                  enable = false;
                };
              };
              run = {
                enable = true;
              };
              debug = {
                enable = true;
              };
            };
          };
        };

        clangd = {
          initialization_options = {
            fallbackFlags = [ "-std=c++20" ];
          };
        };
      };
    };
  };
}
