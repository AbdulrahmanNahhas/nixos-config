{
  programs.helix = {
    enable = true;

    settings = {
      # Rendered at runtime into ~/.config/helix/themes/noctalia.toml by
      # noctalia's builtin "helix" theme template (see home/wm/noctalia),
      # so the editor tracks the rest of the desktop's colour scheme.
      theme = "noctalia";

      editor = {
        line-number = "relative";
        cursorline = true;
        mouse = true;
        true-color = true;

        file-picker.hidden = false;
      };

      # ── Keybinds ─────────────────────────────────────────
      keys = {
        normal = {
          C-s = ":w";
          C-q = ":q";
          C-z = "undo";
          C-a = "select_all";
          C-c = [
            "select_mode"
            "yank_main_selection_to_clipboard"
            "normal_mode"
          ];
          C-v = "paste_clipboard_after";
          "C-/" = "toggle_comments";

          # Move the current line up/down.
          C-A-up = [
            "extend_to_line_bounds"
            "delete_selection"
            "move_line_up"
            "paste_before"
          ];
          C-A-down = [
            "extend_to_line_bounds"
            "delete_selection"
            "move_line_down"
            "paste_after"
          ];
        };

        select = {
          C-c = [
            "yank_main_selection_to_clipboard"
            "normal_mode"
          ];
          C-a = "select_all";
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
          C-a = [
            "normal_mode"
            "select_all"
          ];
          C-v = "paste_clipboard_after";
          "C-/" = [
            "normal_mode"
            "toggle_comments"
            "insert_mode"
          ];
        };
      };
    };
  };
}
