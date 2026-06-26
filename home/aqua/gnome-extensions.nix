# GNOME Shell extensions — installed declaratively as user packages
{ pkgs, ... }:

{
  home.packages = with pkgs.gnomeExtensions; [
    # ── Enabled extensions ─────────────────────────────────
    user-themes                     # load shell themes from ~/.themes or ~/.local/share/themes
    appindicator                    # tray icons for AppIndicators
    dash-to-dock                    # macOS-style dock
    blur-my-shell                   # blur effects
    wallpaper-slideshow
    clipboard-indicator             # clipboard manager
    caffeine                        # disable screensaver
    just-perfection                 # tweak GNOME Shell behaviour
    status-area-horizontal-spacing  # adjustable top-bar spacing
  ];
}
