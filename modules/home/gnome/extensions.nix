{
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
    # wallpaper-slideshow # not needed - for now
    clipboard-indicator
    caffeine
    just-perfection
    status-area-horizontal-spacing
    gsconnect
    auto-accent-colour
    accent-directories
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
      "org.keepassxc.KeePassXC.desktop"
      "io.github.sniper1720.khushu.desktop"
      "org.gnome.Settings.desktop"
      "io.gitlab.news_flash.NewsFlash.desktop"
      "librewolf.desktop"
      "nixos-manual.desktop"
      "obsidian.desktop"
      "org.onlyoffice.desktopeditors.desktop"
      "chat.simplex.simplex.desktop"
      "org.telegram.desktop.desktop"
      "dev.geopjr.Tuba.desktop"
    ])
  ];
in
{
  # ──────────────────────────────────────────────────────────────────
  # HOW TO SYNC LIVE SETTINGS BACK INTO THIS FILE
  #
  # Workflow: tweak an extension's settings in the "Extensions" app (or
  # its own preferences window), then dump the relevant dconf path and
  # diff it against what's declared below.
  #
  # 1) Dump ALL current GNOME Shell + extension settings to a file:
  #
  #      dconf dump /org/gnome/shell/ > /tmp/shell-settings-before.ini
  #
  #    Tweak something in the Extensions app / prefs window, then:
  #
  #      dconf dump /org/gnome/shell/ > /tmp/shell-settings-after.ini
  #      diff /tmp/shell-settings-before.ini /tmp/shell-settings-after.ini
  #
  #    The diff shows you exactly which keys changed and their new
  #    values — copy those into the matching attrset below.
  #
  # 2) Or dump just one extension's settings directly (faster, if you
  #    already know which extension you touched), e.g. for dash-to-dock:
  #
  #      dconf dump /org/gnome/shell/extensions/dash-to-dock/
  #
  #    This prints an INI-style block like:
  #
  #      [/]
  #      dash-max-icon-size=48
  #      dock-position='BOTTOM'
  #
  #    Translate `key=value` -> `key = value;` (strip quotes on enums
  #    Nix already treats as strings, booleans/ints copy as-is).
  #
  # 3) To read a single key instead of a whole subtree:
  #
  #      dconf read /org/gnome/shell/extensions/just-perfection/animation
  #
  # 4) After editing this file, rebuild and re-check with `dconf dump`
  #    again to confirm the declared config actually took effect:
  #
  #      home-manager switch
  #      dconf dump /org/gnome/shell/ > /tmp/shell-settings-rebuilt.ini
  #      diff /tmp/shell-settings-after.ini /tmp/shell-settings-rebuilt.ini
  #
  #    (should be empty/no diff if everything was captured correctly)
  # ──────────────────────────────────────────────────────────────────

  home.packages = extensionPackages;

  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = enabledUuids;
      disabled-extensions = disabledUuids;
      favorite-apps = [
        "com.mitchellh.ghostty.desktop"
        "dev.zed.Zed.desktop"
        "librewolf.desktop"
        "org.gnome.Nautilus.desktop"
        "org.signal.Signal.desktop"
      ];
      app-picker-layout = appPickerLayout;
    };

    # ────────────── Dash to Dock ────────────────────────────
    "org/gnome/shell/extensions/dash-to-dock" = {
      always-center-icons = true;
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
      preview-size-scale = 0.45;
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
      blur = false;
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
      style-components = 3;
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = true;
      brightness = 1.0;
      corner-radius = 0;
      force-light-text = false;
      override-background = true;
      override-background-dynamically = true;
      pipeline = "pipeline_default";
      sigma = 0;
      static-blur = false;
      style-panel = 3;
      unblur-in-overview = true;
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-panel" = {
      blur-original-panel = true;
    };

    "org/gnome/shell/extensions/blur-my-shell/hidetopbar" = {
      compatibility = true;
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
      indicator-position-max = 3;
      user-enabled = false;
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
      controls-manager-spacing-size = 0;
      dash = true;
      dash-separator = true;
      invert-calendar-column-items = false;
      keyboard-layout = true;
      panel = true;
      panel-in-overview = true;
      panel-size = 0;
      power-icon = true;
      quick-settings = true;
      quick-settings-airplane-mode = true;
      quick-settings-backlight = true;
      quick-settings-dark-mode = false;
      screen-recording-indicator = true;
      startup-status = 0;
      support-notifier-showed-version = 36;
      support-notifier-type = 0;
      theme = false;
      top-panel-position = 0;
      type-to-search = true;
      weather = true;
      window-demands-attention-focus = true;
      window-maximized-on-create = true;
      workspace = true;
      workspace-background-corner-size = 0;
      workspace-switcher-should-show = true;
      workspace-switcher-size = 0;
      workspace-thumbnail-to-main-view = true;
      workspace-wrap-around = true;
      workspaces-in-app-grid = true;
      world-clock = true;
    };

    # ────────────── Wallpaper Slideshow ─────────────────────
    # "org/gnome/shell/extensions/azwallpaper" = {
    #   slideshow-directory = "/home/aqua/Pictures/Wallpapers";
    #   slideshow-pause = true;
    #   slideshow-pause-on-fullscreen = true;
    #   slideshow-slide-duration = lib.hm.gvariant.mkTuple [
    #     0
    #     2
    #     0
    #   ];
    #   slideshow-use-absolute-time-for-duration = false;
    # };

    # ────────────── Status Area Horizontal Spacing ──────────
    "org/gnome/shell/extensions/status-area-horizontal-spacing" = {
      hpadding = 3;
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
