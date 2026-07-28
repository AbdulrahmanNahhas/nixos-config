let
  flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";

  # Every app in this list is currently publisher-verified by Flathub.
  verifiedApps = [
    "chat.simplex.simplex"
    "com.belmoussaoui.Authenticator"
    "com.brave.Browser"
    "com.github.ADBeveridge.Raider"
    "dev.geopjr.Tuba"
    "io.github.sniper1720.khushu"
    "io.gitlab.news_flash.NewsFlash"
    "io.gitlab.theevilskeleton.Upscaler"
    "org.gnome.Fractal"
    "org.onlyoffice.desktopeditors"
    "org.telegram.desktop"
    "io.github.diegopvlk.Cine"
  ];
in
{
  services.flatpak = {
    enable = true;

    # Use the restricted remote by default. Signal's Flathub package is
    # community-maintained, so it remains an explicit, documented exception.
    remotes = [
      {
        name = "flathub-verified";
        location = flathub;
        args = "--subset=verified";
      }
      {
        name = "flathub";
        location = flathub;
      }
    ];

    packages =
      map (appId: {
        inherit appId;
        origin = "flathub-verified";
      }) verifiedApps
      ++ [
        {
          appId = "org.signal.Signal";
          origin = "flathub";
        }
      ];

    # Security-sensitive desktop apps should not wait for a system rebuild to
    # receive browser/runtime patches. The persistent timer catches missed runs
    # after sleep or power-off.
    update = {
      onActivation = false;
      auto = {
        enable = true;
        onCalendar = "daily";
      };
    };

    # This module is authoritative for system Flatpaks and their remotes.
    uninstallUnmanaged = true;
    uninstallUnused = true;

    overrides = {
      global.Environment.XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";

      # Prefer the Wayland isolation boundary on the Niri host. SimpleX is
      # intentionally excluded because its current manifest exposes X11 only.
      "com.brave.Browser".Context.sockets = [
        "!x11"
        "wayland"
      ];
      "com.belmoussaoui.Authenticator".Context = {
        shared = [ "!network" ];
        sockets = [
          "!x11"
          "wayland"
        ];
      };
      "com.github.ADBeveridge.Raider".Context.sockets = [
        "!x11"
        "wayland"
      ];
      "dev.geopjr.Tuba".Context.sockets = [
        "!x11"
        "wayland"
      ];
      "io.github.sniper1720.khushu".Context.sockets = [
        "!x11"
        "wayland"
      ];
      "io.gitlab.news_flash.NewsFlash".Context.sockets = [
        "!x11"
        "wayland"
      ];
      "io.gitlab.theevilskeleton.Upscaler".Context.sockets = [
        "!x11"
        "wayland"
      ];
      "org.gnome.Fractal".Context.sockets = [
        "!x11"
        "wayland"
      ];
      "org.telegram.desktop".Context.sockets = [
        "!x11"
        "wayland"
      ];

      # Portals and narrowly-scoped paths replace blanket home/host access.
      "chat.simplex.simplex".Context.filesystems = [
        "!home"
        "xdg-download"
      ];
      "org.onlyoffice.desktopeditors".Context = {
        filesystems = [
          "!host"
          "xdg-documents"
          "xdg-download"
        ];
        sockets = [
          "!x11"
          "wayland"
        ];
      };
    };
  };
}
