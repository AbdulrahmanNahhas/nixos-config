{ ... }:
{
  programs.helix = {
    enable = true;

    # extraPackages = with pkgs; [ ];

    settings = {
      # Noctalia dynamic theme.
      theme = "noctalia";

      editor = {
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        true-color = true;
        mouse = true;

        scrolloff = 5;
        scroll-lines = 3;
        bufferline = "multiple";
        popup-border = "all";

        gutters = [
          "diff"
          "diagnostics"
          "line-numbers"
          "spacer"
        ];

        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };

        auto-pairs = true;
        auto-completion = true;
        path-completion = true;
        auto-info = true;
        completion-timeout = 100;
        completion-trigger-len = 2;

        auto-format = true;

        indent-guides = {
          render = true;
          character = "│";
          skip-levels = 1;
        };

        end-of-line-diagnostics = "hint";

        inline-diagnostics = {
          cursor-line = "warning";
          other-lines = "disable";
        };

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        file-picker = {
          hidden = false;
          git-ignore = true;
          follow-symlinks = true;
        };

        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "file-modification-indicator"
          ];

          right = [
            "diagnostics"
            "selections"
            "position"
            "file-type"
          ];

          separator = "│";

          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };
      };

      keys = {
        normal = {
          C-s = ":w";
          C-q = ":q";
          C-z = "undo";
          C-y = "redo";

          C-a = "select_all";
          C-c = "yank_to_clipboard";
          C-v = "paste_clipboard_after";

          C-p = "file_picker";
          C-S-p = "command_palette";
          C-S-f = "global_search";

          "C-/" = "toggle_comments";

          F2 = "rename_symbol";
          F12 = "goto_definition";
          S-F12 = "goto_reference";

          A-ret = "code_action";

          F8 = "goto_next_diag";
          S-F8 = "goto_prev_diag";
        };

        select = {
          C-a = "select_all";
          C-c = "yank_to_clipboard";
          C-v = "paste_clipboard_after";
          "C-/" = "toggle_comments";
        };

        insert = {
          C-s = [
            "normal_mode"
            ":w"
          ];

          C-q = [
            "normal_mode"
            ":q"
          ];

          C-z = [
            "normal_mode"
            "undo"
          ];

          C-y = [
            "normal_mode"
            "redo"
          ];
        };
      };
    };

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixfmt";
        }
        {
          name = "lua";
          auto-format = true;
          formatter.command = "stylua";
          formatter.args = [ "-" ];
        }
        {
          name = "toml";
          auto-format = true;
          formatter.command = "taplo";
          formatter.args = [
            "format"
            "-"
          ];
        }
        {
          name = "bash";
          auto-format = true;
          formatter.command = "shfmt";
          formatter.args = [
            "-i"
            "2"
          ];
        }
        {
          name = "rust";
          auto-format = true;
        }
      ];
    };
  };
}
