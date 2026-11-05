{ pkgs, ... }:
let
  yatlineRounded = pkgs.runCommand "yatline-rounded-0.5.0" { } ''
    mkdir -p "$out"
    cp -r ${pkgs.yaziPlugins.yatline}/. "$out/"
    chmod u+w "$out/main.lua"

    ${pkgs.python3}/bin/python3 - "$out/main.lua" <<'PY'
    import pathlib
    import sys

    path = pathlib.Path(sys.argv[1])
    source = path.read_text()

    left = "return ui.Line({ section_a_line, section_b_line, section_c_line })"
    right = "return ui.Line({ section_c_line, section_b_line, section_a_line })"

    assert source.count(left) == 1, "Unsupported Yatline left-side layout"
    assert source.count(right) == 1, "Unsupported Yatline right-side layout"

    # Add a left-facing cap before the first visible component.
    source = source.replace(left, """
            set_mode_style(cx.active.mode)
            local bg = #section_a_components > 0 and Yatline.config.style_a.bg
                or #section_b_components > 0 and Yatline.config.style_b.bg
                or Yatline.config.style_c.bg
            local cap = ui.Span("")
            if bg ~= "reset" then
                cap = ui.Span(Yatline.config.section_separator.open):fg(bg)
            end
            return ui.Line({ cap, section_a_line, section_b_line, section_c_line })
    """.strip())

    # Add a right-facing cap after the last visible component.
    source = source.replace(right, """
            set_mode_style(cx.active.mode)
            local bg = #section_a_components > 0 and Yatline.config.style_a.bg
                or #section_b_components > 0 and Yatline.config.style_b.bg
                or Yatline.config.style_c.bg
            local cap = ui.Span("")
            if bg ~= "reset" then
                cap = ui.Span(Yatline.config.section_separator.close):fg(bg)
            end
            return ui.Line({ section_c_line, section_b_line, section_a_line, cap })
    """.strip())

    path.write_text(source)
    PY
  '';
in
{

  programs.yazi = {
    enable = true;

    # External configuration files.
    settings = fromTOML (builtins.readFile ./yazi.toml);

    keymap = fromTOML (builtins.readFile ./keymap.toml);

    plugins = {
      # File-level Git status indicators.
      git = {
        package = pkgs.yaziPlugins.git;
        setup = true;
      };

      # Git branch and repository status for Yatline.
      yatline-githead = pkgs.yaziPlugins.yatline-githead;
      lazygit = pkgs.yaziPlugins.lazygit;
      ouch = pkgs.yaziPlugins.ouch;

      yatline = {
        package = yatlineRounded;
        setup = true;

        settings = {
          # ── Rounded separators ──────────

          section_separator = {
            open = "";
            close = "";
          };

          part_separator = {
            open = " ";
            close = " ";
          };

          inverse_separator = {
            open = "";
            close = "";
          };

          padding = {
            inner = 1;
            outer = 1;
          };

          # ── Ghostty / Noctalia colors ───

          style_a = {
            fg = "black";

            bg_mode = {
              normal = "blue";
              select = "green";
              un_set = "red";
            };
          };

          style_b = {
            bg = "black";
            fg = "brightwhite";
          };

          style_c = {
            bg = "black";
            fg = "brightblue";
          };

          show_background = false;

          # ── Display ─────────────────────

          display_header_line = true;
          display_status_line = true;

          component_positions = [
            "header"
            "tab"
            "status"
          ];

          # ── TOP BAR ─────────────────────

          header_line = {
            left = {
              section_a = [ ];
              section_b = [ ];

              # Full current directory.
              # Uses the low-emphasis style.
              section_c = [
                {
                  type = "string";
                  name = "tab_path";
                  params = [
                    false
                    24
                    10
                  ];
                }
              ];
            };

            right = {
              section_a = [ ];

              # Git repository status.
              # Empty outside Git repositories.
              section_b = [
                {
                  type = "coloreds";
                  name = "githead";
                }
              ];

              # Clock.
              section_c = [
                {
                  type = "string";
                  name = "date";
                  params = [ "%H:%M" ];
                }
              ];
            };
          };

          # ── BOTTOM BAR ──────────────────

          status_line = {
            left = {
              # NORMAL / SELECT / UNSET
              section_a = [
                {
                  type = "string";
                  name = "tab_mode";
                }
              ];

              # Current file or directory.
              section_b = [
                {
                  type = "string";
                  name = "hovered_name";
                  params = [
                    true
                    28
                    12
                    false
                  ];
                }
              ];

              # File size.
              section_c = [
                {
                  type = "string";
                  name = "hovered_size";
                }
              ];
            };

            right = {
              # File position, e.g. 2/6.
              section_a = [
                {
                  type = "string";
                  name = "cursor_position";
                }
              ];

              # Search and filter information.
              section_b = [
                {
                  type = "string";
                  name = "search_query";
                  params = [ "Search:" ];
                }
                {
                  type = "string";
                  name = "filter_query";
                  params = [ "Filter:" ];
                }
              ];

              section_c = [ ];
            };
          };
        };
      };
    };

    # Initialize Githead after Yatline.
    # Keep repository information compact.
    initLua = ''
      require("yatline-githead"):setup({
        order = {
          "branch",
          "behind_ahead_remote",
          "staged",
          "unstaged",
          "untracked",
        },

        show_numbers = true,

        show_branch = true,
        branch_prefix = "",
        branch_symbol = " ",
        branch_color = "brightblue",
        branch_borders = "",

        show_remote_branch = false,
        show_tag = false,
        show_commit = false,
        show_stashes = false,
        show_state = false,

        show_behind_ahead_remote = true,
        ahead_remote_symbol = "↑",
        behind_remote_symbol = "↓",
        ahead_remote_color = "brightgreen",
        behind_remote_color = "brightred",

        show_staged = true,
        staged_symbol = "+",
        staged_color = "brightgreen",

        show_unstaged = true,
        unstaged_symbol = "~",
        unstaged_color = "brightyellow",

        show_untracked = true,
        untracked_symbol = "?",
        untracked_color = "brightred",
      })
    '';

    flavors = { };
  };
}
