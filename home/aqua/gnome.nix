# GNOME desktop settings — declarative dconf configuration
#
# Captured from live system on 2026-06-27 via:
#   dconf dump /org/gnome/desktop/
#   dconf dump /org/gnome/shell/
#   dconf dump /org/gnome/settings-daemon/plugins/color/
#   dconf dump /org/gnome/mutter/
#
# How to refresh after GUI tweaks:
#   1. Run the dconf dump commands above
#   2. Convert the output to Nix using these rules:
#      - Regular bool/int/float/string → Nix literal
#      - GVariant tuples like ('xkb','us') → lib.hm.gvariant.mkTuple [...]
#      - Typed arrays of tuples → lib.hm.gvariant.mkArray (type) [...]
#      - uint32 values → lib.hm.gvariant.mkUint32 N
#      - Empty arrays like @as [] → []  (Nix list)
#   3. For complex values like app-picker-layout, reorder via GUI instead
{
  config,
  lib,
  ...
}:

let
  # Shorthand for tuple-of-strings array used by input-sources
  strTupleType = lib.hm.gvariant.type.tupleOf [
    lib.hm.gvariant.type.string
    lib.hm.gvariant.type.string
  ];
in

{
  dconf.settings = {

    # ═══════════════════════════════════════════════════════════════
    #  Desktop Interface
    # ═══════════════════════════════════════════════════════════════
    "org/gnome/desktop/interface" = {
      # ── Theme ──────────────────────────────────────────
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
      icon-theme = "Papirus-Dark";
      cursor-theme = "Bibata-Modern-Ice";
      cursor-size = 26;

      # ── Fonts ──────────────────────────────────────────
      font-name = "Adwaita Sans 12";
      document-font-name = "Adwaita Sans 12";
      monospace-font-name = "GeistMono Nerd Font Mono 12";
      font-hinting = "slight";

      # ── Behaviour ──────────────────────────────────────
      enable-animations = true;
      show-battery-percentage = true;
    };

    # ═══════════════════════════════════════════════════════════════
    #  Background / Wallpaper
    # ═══════════════════════════════════════════════════════════════
    "org/gnome/desktop/background" = {
      picture-uri = "file:///home/aqua/Pictures/Wallpapers/Scenes/weathering-you.png";
      picture-uri-dark = "file:///home/aqua/Pictures/Wallpapers/Scenes/weathering-you.png";
    };

    # ═══════════════════════════════════════════════════════════════
    #  Input Sources (Keyboard Layouts)
    # ═══════════════════════════════════════════════════════════════
    "org/gnome/desktop/input-sources" = {
      show-all-sources = false;
      sources = lib.hm.gvariant.mkArray strTupleType [
        (lib.hm.gvariant.mkTuple [ "xkb" "us" ])  # English (US)
        (lib.hm.gvariant.mkTuple [ "xkb" "ara" ]) # Arabic
      ];
      mru-sources = lib.hm.gvariant.mkArray strTupleType [
        (lib.hm.gvariant.mkTuple [ "xkb" "us" ])  # English (US)
        (lib.hm.gvariant.mkTuple [ "xkb" "ara" ]) # Arabic
      ];
      xkb-options = lib.hm.gvariant.mkArray lib.hm.gvariant.type.string [ ];
    };

    # ═══════════════════════════════════════════════════════════════
    #  Peripherals
    # ═══════════════════════════════════════════════════════════════
    "org/gnome/desktop/peripherals/mouse" = {
      speed = 0.6;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    # ═══════════════════════════════════════════════════════════════
    #  Privacy
    # ═══════════════════════════════════════════════════════════════
    "org/gnome/desktop/privacy" = {
      disable-camera = true;
      remove-old-temp-files = true;
      remove-old-trash-files = true;
    };

    # ═══════════════════════════════════════════════════════════════
    #  Notifications
    # ═══════════════════════════════════════════════════════════════
    "org/gnome/desktop/notifications" = {
      show-in-lock-screen = true;
      application-children = [ "org-gnome-tweaks" ];
    };
    "org/gnome/desktop/notifications/application/org-gnome-tweaks" = {
      application-id = "org.gnome.tweaks.desktop";
    };

    # ═══════════════════════════════════════════════════════════════
    #  Search Providers
    # ═══════════════════════════════════════════════════════════════
    "org/gnome/desktop/search-providers" = {
      enabled = [ "com.belmoussaoui.Authenticator.desktop" ];
      sort-order = [
        "org.gnome.Settings.desktop"
        "org.gnome.Contacts.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };

    # ═══════════════════════════════════════════════════════════════
    #  App Folders (app-grid organisation)
    # ═══════════════════════════════════════════════════════════════
    "org/gnome/desktop/app-folders" = {
      folder-children = [
        "System"
        "Utilities"
        "YaST"
        "Pardus"
        "351e0451-6bef-4f3d-95e2-16c13fd65f91"  # "Utils" folder — user-created
      ];
    };

    "org/gnome/desktop/app-folders/folders/351e0451-6bef-4f3d-95e2-16c13fd65f91" = {
      apps = [
        "com.github.ADBeveridge.Raider.desktop"
        "com.github.tchx84.Flatseal.desktop"
        "org.gnome.tweaks.desktop"
        "micro.desktop"
        "btop.desktop"
        "yazi.desktop"
        "org.gnome.Extensions.desktop"
      ];
      name = "Utils";
      translate = false;
    };

    "org/gnome/desktop/app-folders/folders/Pardus" = {
      categories = [ "X-Pardus-Apps" ];
      name = "X-Pardus-Apps.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/System" = {
      apps = [
        "nvidia-settings.desktop"
        "org.gnome.baobab.desktop"
        "org.gnome.DiskUtility.desktop"
        "org.gnome.Logs.desktop"
        "org.gnome.SystemMonitor.desktop"
      ];
      name = "X-GNOME-Shell-System.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [
        "org.gnome.Decibels.desktop"
        "org.gnome.Papers.desktop"
        "org.gnome.font-viewer.desktop"
        "org.gnome.Loupe.desktop"
        "org.gnome.seahorse.Application.desktop"
        "org.gnome.SimpleScan.desktop"
        "org.gnome.Showtime.desktop"
        "org.gnome.Snapshot.desktop"
        "org.gnome.Calculator.desktop"
        "org.gnome.Maps.desktop"
        "org.gnome.Contacts.desktop"
        "org.gnome.Weather.desktop"
        "org.gnome.clocks.desktop"
        "org.gnome.Music.desktop"
        "org.gnome.TextEditor.desktop"
      ];
      name = "GNOME Apps";
      translate = false;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = [ "X-SuSE-YaST" ];
      name = "suse-yast.directory";
      translate = true;
    };

    # ═══════════════════════════════════════════════════════════════
    #  Break Reminders (Health)
    # ═══════════════════════════════════════════════════════════════
    "org/gnome/desktop/break-reminders" = {
      selected-breaks = [ "eyesight" "movement" ];
    };

    "org/gnome/desktop/break-reminders/eyesight" = {
      play-sound = false;
    };

    "org/gnome/desktop/break-reminders/movement" = {
      duration-seconds = lib.hm.gvariant.mkUint32 300;
      interval-seconds = lib.hm.gvariant.mkUint32 1800;
      play-sound = false;
    };

    # ═══════════════════════════════════════════════════════════════
    #  Night Light  (Settings → Displays → Night Light)
    # ═══════════════════════════════════════════════════════════════
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = false;
      night-light-schedule-from = 2.0;               # 02:00
      night-light-schedule-to = 1.9833333333333334;  # ≈ 01:59  (all-day)
      night-light-temperature = lib.hm.gvariant.mkUint32 3291;
    };

    # ═══════════════════════════════════════════════════════════════
    #  Mutter (Window Manager / Compositor)
    # ═══════════════════════════════════════════════════════════════
    "org/gnome/mutter" = {
      overlay-key = "Super_L";
      workspaces-only-on-primary = true;
    };

    # ═══════════════════════════════════════════════════════════════
    #  NOTE: app-picker-layout is intentionally omitted
    #
    #  The app-picker-layout value is a deeply nested GVariant
    #  structure (array of dictionaries of variants) that encodes
    #  the exact position of every app icon on every page of the
    #  app grid. It is highly volatile and impractical to maintain
    #  declaratively in Nix.
    #
    #  If you rearrange your app grid via the GUI, the new layout
    #  persists in dconf until the next `home-manager switch`.
    #  Since we don't set this key, your manual arrangement is
    #  preserved (home-manager only writes keys we explicitly
    #  declare — it never resets unspecified keys).
    #
    #  To capture a one-off snapshot regardless:
    #    $ dconf dump /org/gnome/shell/app-picker-layout/
    # ═══════════════════════════════════════════════════════════════

  };
}
