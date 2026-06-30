{ lib, pkgs, ... }:
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
    gsconnect
    dynamic-music-pill
  ];

  extensionUuids = builtins.map (p: p.extensionUuid) extensionPackages;
  disabledUuids = [ pkgs.gnomeExtensions.gsconnect.extensionUuid ];
  enabledUuids = builtins.filter (u: !(builtins.elem u disabledUuids)) extensionUuids;

  svEntryType = lib.hm.gvariant.type.dictionaryEntryOf [
    lib.hm.gvariant.type.string
    lib.hm.gvariant.type.variant
  ];

  mkEntry =
    key: value:
    lib.hm.gvariant.mkDictionaryEntry [
      (lib.hm.gvariant.mkString key)
      (lib.hm.gvariant.mkVariant value)
    ];

  mkVardict = entries: lib.hm.gvariant.mkArray svEntryType (map (e: mkEntry e.name e.value) entries);

  mkPage =
    apps:
    mkVardict (
      lib.imap0 (pos: id: {
        name = id;
        value = mkVardict [
          {
            name = "position";
            value = lib.hm.gvariant.mkInt32 pos;
          }
        ];
      }) apps
    );

  appPickerLayout = lib.hm.gvariant.mkArray (lib.hm.gvariant.type.arrayOf svEntryType) [
    (mkPage [
      "System"
      "Utilities"
      "351e0451-6bef-4f3d-95e2-16c13fd65f91"
      "com.belmoussaoui.Authenticator.desktop"
      "com.brave.Browser.desktop"
      "org.gnome.Fractal.desktop"
      "de.wwwtech.gitte.desktop"
      "org.keepassxc.KeePassXC.desktop"
      "io.github.sniper1720.khushu.desktop"
      "org.gnome.Settings.desktop"
      "io.gitlab.news_flash.NewsFlash.desktop"
      "nixos-manual.desktop"
      "obsidian.desktop"
      "org.onlyoffice.desktopeditors.desktop"
      "opencode-desktop.desktop"
      "org.gnome.World.Secrets.desktop"
      "chat.simplex.simplex.desktop"
      "org.telegram.desktop.desktop"
      "dev.geopjr.Tuba.desktop"
      "dev.vencord.Vesktop.desktop"
    ])
  ];
in
{
  home.packages = extensionPackages;

  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = enabledUuids;
      disabled-extensions = disabledUuids;
      favorite-apps = [
        "com.mitchellh.ghostty.desktop"
        "dev.zed.Zed.desktop"
        "firefox.desktop"
        "org.gnome.Nautilus.desktop"
        "org.signal.Signal.desktop"
      ];
      app-picker-layout = appPickerLayout;
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
    "org/gnome/shell/extensions/azwallpaper" = {
      slideshow-directory = "/home/aqua/Pictures/Wallpapers/Scenes";
      slideshow-pause = true;
      slideshow-pause-on-fullscreen = true;
      slideshow-slide-duration = lib.hm.gvariant.mkTuple [
        0
        2
        0
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
  };
}
