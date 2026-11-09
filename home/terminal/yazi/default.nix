{ config, pkgs, ... }:

let
  # ── External Yazi configuration ────────────────────────

  settings = fromTOML (builtins.readFile ./yazi.toml);

  # ── Custom Yatline ─────────────────────────────────────
  #
  # Based on the Yatline package from Nixpkgs.
  #
  # Patches:
  #   1. Rounded status/header end caps.
  #   2. Yazi 26.9.1 Url API compatibility.
  #
  # Keep these patches until upstream supports them.

  yatlineRounded = pkgs.runCommand "yatline-rounded-0.5.0" { } ''
    mkdir -p "$out"
    cp -r ${pkgs.yaziPlugins.yatline}/. "$out/"
    chmod u+w "$out/main.lua"

    ${pkgs.python3}/bin/python3 - "$out/main.lua" <<'PY'
    import pathlib
    import sys

    path = pathlib.Path(sys.argv[1])
    source = path.read_text()

    # ── 1. Rounded separators ──────────────────────────

    left = (
        "return ui.Line({ section_a_line, "
        "section_b_line, section_c_line })"
    )

    right = (
        "return ui.Line({ section_c_line, "
        "section_b_line, section_a_line })"
    )

    assert source.count(left) == 1, (
        "Unsupported Yatline left-side layout"
    )

    assert source.count(right) == 1, (
        "Unsupported Yatline right-side layout"
    )

    # Left-facing cap before the first visible section.

    source = source.replace(left, """
            set_mode_style(cx.active.mode)

            local bg = #section_a_components > 0 and Yatline.config.style_a.bg
                or #section_b_components > 0 and Yatline.config.style_b.bg
                or Yatline.config.style_c.bg

            local cap = ui.Span("")

            if bg ~= "reset" then
                cap = ui.Span(Yatline.config.section_separator.open):fg(bg)
            end

            return ui.Line({
                cap,
                section_a_line,
                section_b_line,
                section_c_line,
            })
    """.strip())

    # Right-facing cap after the last visible section.

    source = source.replace(right, """
            set_mode_style(cx.active.mode)

            local bg = #section_a_components > 0 and Yatline.config.style_a.bg
                or #section_b_components > 0 and Yatline.config.style_b.bg
                or Yatline.config.style_c.bg

            local cap = ui.Span("")

            if bg ~= "reset" then
                cap = ui.Span(Yatline.config.section_separator.close):fg(bg)
            end

            return ui.Line({
                section_c_line,
                section_b_line,
                section_a_line,
                cap,
            })
    """.strip())

    # ── 2. Yazi 26.9.1 API compatibility ───────────────
    #
    # Deprecated:
    #   Url.is_search
    #
    # Replacement:
    #   Url.spec.is_search
    #
    # Yatline 0.5.0 contains three affected references.
    # Assert the count to catch unexpected upstream changes.

    old = ".is_search"
    new = ".spec.is_search"

    assert source.count(old) == 3, (
        "Unexpected Yatline Url.is_search references"
    )

    source = source.replace(old, new)

    # ── Write patched plugin ───────────────────────────

    path.write_text(source)
    PY
  '';

in
{
  programs.yazi = {
    enable = true;

    # ── General configuration ────────────────────────────

    settings = settings // {
      open = settings.open // {
        prepend_rules = [
          {
            url = "${config.home.homeDirectory}/Pictures/Wallpapers/**/*.{jpg,jpeg,png,webp,avif,gif}";
            use = [
              "wallpaper"
              "system"
            ];
          }
        ]
        ++ settings.open.prepend_rules;
      };
    };

    # ── Keybindings ──────────────────────────────────────

    keymap = fromTOML (builtins.readFile ./keymap.toml);

    # ── Plugins ──────────────────────────────────────────

    plugins = {
      # File-level Git status indicators.
      git = {
        package = pkgs.yaziPlugins.git;
        setup = true;
      };

      # Git repository information for Yatline.
      yatline-githead = pkgs.yaziPlugins.yatline-githead;

      # Git interface.
      lazygit = pkgs.yaziPlugins.lazygit;

      # Archive handling.
      ouch = pkgs.yaziPlugins.ouch;

      # ── Yatline status/header bars ────────────────────

      yatline = {
        package = yatlineRounded;
        setup = true;

        settings = {
          # ── Rounded separators ────────────────────────

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

          # ── Ghostty / Noctalia colors ─────────────────

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

          # ── Display ───────────────────────────────────

          display_header_line = true;
          display_status_line = true;

          component_positions = [
            "header"
            "tab"
            "status"
          ];

          # ── Top bar ───────────────────────────────────

          header_line = {
            left = {
              section_a = [ ];
              section_b = [ ];

              # Current directory.
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

              # Git branch and repository status.
              section_b = [
                {
                  type = "coloreds";
                  name = "githead";
                }
              ];

              # Current time.
              section_c = [
                {
                  type = "string";
                  name = "date";
                  params = [ "%H:%M" ];
                }
              ];
            };
          };

          # ── Bottom bar ────────────────────────────────

          status_line = {
            left = {
              # NORMAL / SELECT / UNSET.
              section_a = [
                {
                  type = "string";
                  name = "tab_mode";
                }
              ];

              # Selected file/directory.
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
              # Current file position.
              section_a = [
                {
                  type = "string";
                  name = "cursor_position";
                }
              ];

              # Active search and filter.
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

    # ── Githead initialization ───────────────────────────
    #
    # Home Manager initializes configured plugins
    # before appending this initLua content.

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

        -- Branch
        show_branch = true,
        branch_prefix = "",
        branch_symbol = " ",
        branch_color = "brightblue",
        branch_borders = "",

        -- Hide extra repository details
        show_remote_branch = false,
        show_tag = false,
        show_commit = false,
        show_stashes = false,
        show_state = false,

        -- Remote tracking
        show_behind_ahead_remote = true,
        ahead_remote_symbol = "↑",
        behind_remote_symbol = "↓",
        ahead_remote_color = "brightgreen",
        behind_remote_color = "brightred",

        -- Staged changes
        show_staged = true,
        staged_symbol = "+",
        staged_color = "brightgreen",

        -- Unstaged changes
        show_unstaged = true,
        unstaged_symbol = "~",
        unstaged_color = "brightyellow",

        -- Untracked files
        show_untracked = true,
        untracked_symbol = "?",
        untracked_color = "brightred",
      })
    '';

    # No hardcoded flavor:
    # Noctalia generates Yazi's dynamic theme.
    flavors = { };
  };
}
