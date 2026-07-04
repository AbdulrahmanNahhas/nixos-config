{ lib, ... }:
let
  strTupleType = lib.hm.gvariant.type.tupleOf [
    lib.hm.gvariant.type.string
    lib.hm.gvariant.type.string
  ];
in
{
  # ── Generate Monitor Settings ───────────
  xdg.configFile."monitors.xml".text = ''
    <monitors version="2">
      <configuration>
        <layoutmode>logical</layoutmode>
        <logicalmonitor>
          <x>0</x>
          <y>0</y>
          <scale>2</scale>
          <primary>yes</primary>
          <monitor>
            <monitorspec>
              <connector>eDP-2</connector>
              <vendor>SDC</vendor>
              <product>ATNA40CU05-0 </product>
              <serial>0x00000000</serial>
            </monitorspec>
            <mode>
              <width>2880</width>
              <height>1800</height>
              <rate>60.001</rate>
            </mode>
          </monitor>
        </logicalmonitor>
      </configuration>
    </monitors>
  '';

  # Gnome Files - Sidebar
  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file:///home/aqua/Documents Documents
    file:///home/aqua/Projects Projects
    file:///home/aqua/Music Music
    file:///home/aqua/Pictures Pictures
    file:///home/aqua/Videos Videos
    file:///home/aqua/Books Books
    file:///home/aqua/Downloads Downloads
    file:///saved/nixos-config nixos-config
  '';

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
      icon-theme = "MoreWaita";
      font-name = "Adwaita Sans 12";
      document-font-name = "Adwaita Sans 12";
      monospace-font-name = "GeistMono Nerd Font Mono 12";
      font-hinting = "slight";
      enable-animations = true;
      show-battery-percentage = true;
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file:///home/aqua/Pictures/Wallpapers/my-neighbor-totoro-sunflowers.png";
      picture-uri-dark = "file:///home/aqua/Pictures/Wallpapers/my-neighbor-totoro-sunflowers.png";
    };

    "org/gnome/desktop/input-sources" = {
      show-all-sources = false;
      sources = lib.hm.gvariant.mkArray strTupleType [
        (lib.hm.gvariant.mkTuple [
          "xkb"
          "us"
        ])
        (lib.hm.gvariant.mkTuple [
          "xkb"
          "ara"
        ])
      ];
      mru-sources = lib.hm.gvariant.mkArray strTupleType [
        (lib.hm.gvariant.mkTuple [
          "xkb"
          "us"
        ])
        (lib.hm.gvariant.mkTuple [
          "xkb"
          "ara"
        ])
      ];
      xkb-options = lib.hm.gvariant.mkArray lib.hm.gvariant.type.string [ ];
    };

    "org/gnome/desktop/peripherals/mouse" = {
      speed = 0.6;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      disable-camera = true;
      remove-old-temp-files = true;
      remove-old-trash-files = true;
    };

    "org/gnome/desktop/notifications" = {
      show-in-lock-screen = true;
      application-children = [ "org-gnome-tweaks" ];
    };

    "org/gnome/desktop/notifications/application/org-gnome-tweaks" = {
      application-id = "org.gnome.tweaks.desktop";
    };

    "org/gnome/desktop/search-providers" = {
      enabled = [ "com.belmoussaoui.Authenticator.desktop" ];
      sort-order = [
        "org.gnome.Settings.desktop"
        "org.gnome.Contacts.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [
        "System"
        "Utilities"
        "351e0451-6bef-4f3d-95e2-16c13fd65f91"
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
        "polychromatic.desktop"
        "protontricks.desktop"
        "epsonscan2.desktop"
        "cups.desktop"
      ];
      name = "Utils";
      translate = false;
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
        "org.gnome.Calendar.desktop"
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

    "org/gnome/desktop/break-reminders" = {
      selected-breaks = [
        "eyesight"
        "movement"
      ];
    };

    "org/gnome/desktop/break-reminders/eyesight" = {
      play-sound = false;
    };

    "org/gnome/desktop/break-reminders/movement" = {
      duration-seconds = lib.hm.gvariant.mkUint32 300;
      interval-seconds = lib.hm.gvariant.mkUint32 1800;
      play-sound = false;
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = false;
      night-light-schedule-from = 2.0;
      night-light-schedule-to = 1.9833333333333334;
      night-light-temperature = lib.hm.gvariant.mkUint32 3291;
    };

    "org/gnome/mutter" = {
      overlay-key = "Super_L";
      workspaces-only-on-primary = true;
    };
  };
}
