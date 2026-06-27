# GNOME Shell extensions — installed AND configured declaratively
#
# How to capture live extension settings after tweaking via GUI:
#   1. gnome-extensions list
#      → copy the UUID of the extension you tweaked
#   2. dconf dump /org/gnome/shell/extensions/<uuid>/
#      → paste the output into this file as dconf.settings attrs
#   3. If step 2 returns nothing, try:
#      gsettings list-recursively org.gnome.shell.extensions.<uuid with dots>
#      → map each key: dot-separated path → dconf path with slashes
#   4. Check enabled/disabled lists:
#      dconf dump /org/gnome/shell/
#   5. For tuple values like (0,2,0) use lib.hm.gvariant.mkTuple in Nix
#
# How to find a package's UUID without installing:
#   nix eval nixpkgs#gnomeExtensions.<attr>.extensionUuid
#
{
  # config,
  lib,
  pkgs,
  ...
}:

let
  extensionPackages = with pkgs.gnomeExtensions; [
    user-themes
    appindicator
    dash-to-dock
    blur-my-shell
    wallpaper-slideshow
    clipboard-indicator
    caffeine
    just-perfection
    status-area-horizontal-spacing
    gsconnect # KDE Connect protocol, GNOME-native (firewall opened in configuration.nix)
  ];

  extensionUuids = builtins.map (p: p.extensionUuid) extensionPackages;

  # Installed but not enabled on boot
  disabledUuids = [ pkgs.gnomeExtensions.gsconnect.extensionUuid ];
  enabledUuids = builtins.filter (u: !(builtins.elem u disabledUuids)) extensionUuids;
in

{
  # ── Install extension packages ────────────────────────────
  home.packages = extensionPackages;

  # ── Enable & configure every extension ────────────────────
  dconf.settings = {
    # GNOME 45+ requires explicit enablement
    "org/gnome/shell" = {
      enabled-extensions = enabledUuids;
      disabled-extensions = disabledUuids;
    };

    # ────────────── Dash to Dock ────────────────────────────
    "org/gnome/shell/extensions/dash-to-dock" = {
      apply-custom-theme = true;
      background-opacity = 0.80;
      custom-theme-shrink = true;
      dash-max-icon-size = 48;
      disable-overview-on-startup = false;
      dock-position = "BOTTOM";
      extend-height = false;
      height-fraction = 0.90;
      icon-size-fixed = false;
      isolate-monitors = false;
      multi-monitor = true;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "eDP-2";
      preview-size-scale = 0.0;
      scroll-action = "switch-workspace";
      scroll-to-focused-application = true;
      show-apps-at-top = true;
      show-favorites = true;
    };

    # ────────────── Blur my Shell ───────────────────────────
    # pipelines key omitted — defaults are recreated automatically by the extension
    "org/gnome/shell/extensions/blur-my-shell" = {
      rounded-blur-found = false;
      settings-version = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      blur = true;
      brightness = 0.67;
      sigma = 30;
      style-dialogs = 1;
    };

    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/coverflow-alt-tab" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = true;
      brightness = 0.60;
      override-background = true;
      pipeline = "pipeline_default_rounded";
      sigma = 30;
      static-blur = true;
      style-dash-to-dock = 0;
      unblur-in-overview = true;
    };

    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      pipeline = "pipeline_default";
      style-components = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
      brightness = 0.60;
      corner-radius = 0;
      force-light-text = false;
      override-background = false;
      override-background-dynamically = true;
      pipeline = "pipeline_default";
      sigma = 30;
      static-blur = true;
    };

    "org/gnome/shell/extensions/blur-my-shell/screenshot" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/window-list" = {
      brightness = 0.60;
      sigma = 30;
    };

    # ────────────── Caffeine ─────────────────────────────────
    "org/gnome/shell/extensions/caffeine" = {
      cli-toggle = false;
      indicator-position-max = 4;
    };

    # ────────────── Clipboard Indicator ─────────────────────
    "org/gnome/shell/extensions/clipboard-indicator" = {
      blink-icon-on-copy = false;
      confirm-pinned-delete = true;
      disable-down-arrow = true;
      display-mode = 0;
      history-size = 30;
      topbar-preview-size = 1;
    };

    # ────────────── Just Perfection ─────────────────────────
    "org/gnome/shell/extensions/just-perfection" = {
      accent-color-icon = false;
      accessibility-menu = true;
      activities-button = true;
      animation = 5;
      clock-menu = true;
      clock-menu-position = 0;
      clock-menu-position-offset = 0;
      dash = true;
      dash-separator = true;
      invert-calendar-column-items = false;
      keyboard-layout = true;
      panel = true;
      quick-settings = true;
      quick-settings-airplane-mode = false;
      quick-settings-backlight = true;
      quick-settings-dark-mode = false;
      startup-status = 1;
      support-notifier-showed-version = 36;
      support-notifier-type = 0;
      type-to-search = true;
      weather = true;
      window-demands-attention-focus = true;
      window-maximized-on-create = true;
      workspace-switcher-should-show = true;
      workspace-wrap-around = true;
      world-clock = false;
    };

    # ────────────── Wallpaper Slideshow ─────────────────────
    # Runtime state (slideshow-queue, current-slide-index, etc.) is omitted
    "org/gnome/shell/extensions/azwallpaper" = {
      slideshow-directory = "/home/aqua/Pictures/Wallpapers/Scenes";
      slideshow-pause = true;
      slideshow-pause-on-fullscreen = true;
      slideshow-slide-duration = lib.hm.gvariant.mkTuple [
        0  # hours
        2  # minutes
        0  # seconds
      ];
      slideshow-use-absolute-time-for-duration = false;
    };

    # ────────────── Status Area Horizontal Spacing ──────────
    "org/gnome/shell/extensions/status-area-horizontal-spacing" = {
      hpadding = 0;
    };

    # ────────────── AppIndicator ────────────────────────────
    "org/gnome/shell/extensions/appindicator" = {
      icon-brightness = 0.0;
      icon-contrast = 0.0;
      icon-opacity = 240;
      icon-saturation = 0.0;
      icon-size = 0;
    };

    # ────────────── User Themes ─────────────────────────────
    # No dconf settings — reads shell theme from ~/.themes or ~/.local/share/themes
  };
}
