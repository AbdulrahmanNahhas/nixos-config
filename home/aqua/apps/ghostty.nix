{ ... }:
{
  xdg.configFile."ghostty/config".text = ''
    font-family = "GeistMono Nerd Font"
    font-size = 16
    font-feature = "calt liga zero"
    font-variation = "wght=400"

    # ── Window ─────────────────────────────────────────────
    window-padding-x = 8
    window-padding-y = 4
    window-width = 800
    window-height = 500
    window-decoration = auto
    window-theme = auto
    gtk-titlebar = true
    background-opacity = 0.92

    # ── Theme ──────────────────────────────────────────────
    theme = Adwaita Dark

    # ── Behavior ───────────────────────────────────────────
    confirm-close-surface = false
    copy-on-select = clipboard
    clipboard-trim-trailing-spaces = true
    mouse-hide-while-typing = true

    # ── Keybinds ───────────────────────────────────────────
    keybind = super+c=copy_to_clipboard
    keybind = super+v=paste_from_clipboard
    keybind = super+shift+c=copy_to_clipboard
    keybind = super+shift+v=paste_from_clipboard

    # ── Shell ──────────────────────────────────────────────
    shell-integration = fish
  '';
}
