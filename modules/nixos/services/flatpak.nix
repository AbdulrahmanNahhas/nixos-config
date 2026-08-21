{
  pkgs,
  ...
}:
let
  flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";

  # Every app in this list is currently publisher-verified by Flathub.
  verifiedApps = [
    "chat.simplex.simplex"
    "com.brave.Browser"
    "com.github.ADBeveridge.Raider"
    "dev.geopjr.Tuba"
    "io.gitlab.news_flash.NewsFlash"
    "io.gitlab.theevilskeleton.Upscaler"
    "org.gnome.Fractal"
    "org.telegram.desktop"
    "io.github.diegopvlk.Cine"
    "io.gitlab.adhami3310.Impression"
    "app.drey.EarTag"
    "io.bassi.Amberol"
    "moe.tsuna.tsukimi"
    "dev.geopjr.Archives"
    "org.libreoffice.LibreOffice"
    "io.github.alainm23.planify"
  ];
in
{
  services.flatpak = {
    enable = true;

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

        {
          appId = "io.github.block.Goose";
          bundle = "${pkgs.fetchurl {
            url = "https://github.com/aaif-goose/goose/releases/download/v1.46.0/io.github.block.Goose_stable_x86_64.flatpak";
            hash = "sha256-kNaedAfHx7nW3QyvCS+b0KIGYNYEcPpMAsVyf2uo0Hw=";
          }}";
        }
      ];

    update = {
      onActivation = false;
      auto = {
        enable = true;
        onCalendar = "daily";
      };
    };

    uninstallUnmanaged = true;
    uninstallUnused = true;

    overrides = {
      global = {
        Environment.XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";

        Context = {
          # Strict filesystem block
          filesystems = [
            "!host"
            "!home"
          ];

          # Enforce Wayland and block legacy X11 protocols. Audio remains
          # controlled by each upstream manifest because Flatpak's PulseAudio
          # socket is also the PipeWire compatibility path.
          sockets = [
            "!x11"
            "!fallback-x11"
            "wayland"
          ];

          # Remove broad direct device access inherited from manifests.
          devices = [ "!all" ];

          # Wayland applications do not need the shared IPC namespace that X11
          # commonly requires.
          shared = [ "!ipc" ];
        };
      };

      # --- Exceptions & App-Specific Routing ---

      "chat.simplex.simplex".Context = {
        sockets = [
          "x11"
          "!wayland"
        ];
        shared = [ "ipc" ];
        filesystems = [ "xdg-download" ];
      };

      "com.brave.Browser".Context = {
        filesystems = [ "xdg-download" ];
      };

      "org.onlyoffice.desktopeditors".Context = {
        filesystems = [
          "xdg-documents"
          "xdg-download"
        ];
      };

      "org.signal.Signal".Context = {
        Environment = "ELECTRON_OZONE_PLATFORM_HINT=wayland";
        filesystems = [ "xdg-download" ];
      };

      # Flatpak has no block-device-only permission. Impression therefore needs
      # the broad device grant from its upstream manifest to flash removable
      # drives; keep this explicit because it is a significant exception.
      "io.gitlab.adhami3310.Impression".Context = {
        devices = [ "all" ];
      };

      # --- Local App Network & Filesystem Isolation ---

      "app.drey.EarTag".Context = {
        filesystems = [ "xdg-music" ];
        shared = [ "!network" ];
      };

      "io.github.diegopvlk.Cine".Context = {
        filesystems = [ "xdg-videos" ];
        shared = [ "!network" ];
      };

      "io.gitlab.theevilskeleton.Upscaler".Context = {
        filesystems = [ "xdg-pictures" ];
        shared = [ "!network" ];
      };

      "io.bassi.Amberol".Context = {
        filesystems = [ "xdg-music" ];
        shared = [ "!network" ];
      };
    };
  };
}
