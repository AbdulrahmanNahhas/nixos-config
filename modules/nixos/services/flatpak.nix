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

  # GTK3 theme-switching extensions (published by the GNOME project itself,
  # not part of the verified-apps subset). GTK3 apps that ask for
  # GTK_THEME=adw-gtk3-dark find nothing at all inside the sandbox unless one
  # of these is installed -- flatpak does NOT expose the host's real
  # /usr/share/themes into sandboxes the way it does for fonts and icons.
  # Confirmed live: without this, `flatpak run --command=sh` shows
  # /usr/share/themes containing only the runtime's own bundled "Default"
  # and "Emacs" themes, and GTK3 apps fell back to that plain, unstyled
  # engine (looked broken, not merely "not dark").
  gtkThemeExtensions = [
    "org.gtk.Gtk3theme.adw-gtk3"
    "org.gtk.Gtk3theme.adw-gtk3-dark"
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
      ++ map (appId: {
        inherit appId;
        origin = "flathub";
      }) gtkThemeExtensions
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
        Environment = {
          XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
          # Picked up by GTK3 apps that read GTK_THEME directly instead of
          # relying on the portal Settings interface. The actual theme files
          # come from the org.gtk.Gtk3theme.adw-gtk3-dark flatpak extension
          # above -- without it installed, this variable alone makes GTK3
          # fall back to its plain, unstyled default engine instead of
          # silently ignoring the missing theme.
          GTK_THEME = "adw-gtk3-dark";
        };

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

      "org.libreoffice.LibreOffice".Context = {
        filesystems = [
          "xdg-documents"
          "xdg-download"
          # Read-only access to noctalia's rendered theme state so its
          # post_hook can `unopkg add` the built Noctalia ColorScheme .oxt
          # from ~/.local/state/noctalia into this sandbox. See
          # home/wm/noctalia's community "libreoffice" template.
          #
          # "xdg-state" is not a filesystem category flatpak recognizes (it
          # only knows xdg-{documents,download,music,pictures,...}, plus
          # xdg-{config,cache,data} -- NOT xdg-state). Confirmed live:
          # `flatpak run --verbose` logged "Unknown filesystem type
          # xdg-state/noctalia:ro" and silently dropped the whole app
          # sandbox into a broken state (LibreOffice failed to even start).
          # A literal home-relative path works the same way the
          # "!home" + specific xdg-* exceptions already do elsewhere in
          # this file.
          "~/.local/state/noctalia:ro"
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

      # --- GTK4 Apps Needing dconf Access ---
      # GTK4 apps using libadwaita need to read org/gnome/desktop/interface
      # dconf settings (especially color-scheme for dark theme support).
      "org.gnome.Fractal".Context = {
        filesystems = [ "~/.config/dconf:ro" ];
      };

      "io.gitlab.adhami3310.Impression".Context.filesystems = [
        "~/.config/dconf:ro"
        "xdg-pictures"
      ];

      "io.gitlab.news_flash.NewsFlash".Context = {
        filesystems = [ "~/.config/dconf:ro" ];
      };

      "io.github.alainm23.planify".Context = {
        filesystems = [ "~/.config/dconf:ro" ];
      };

      "moe.tsuna.tsukimi".Context = {
        filesystems = [ "~/.config/dconf:ro" ];
      };

      "io.gitlab.theevilskeleton.Upscaler".Context = {
        filesystems = [
          "~/.config/dconf:ro"
          "xdg-pictures"
        ];
        shared = [ "!network" ];
      };

      # --- Local App Network & Filesystem Isolation ---

      "app.drey.EarTag".Context = {
        filesystems = [
          "~/.config/dconf:ro"
          "xdg-music"
        ];
        shared = [ "!network" ];
      };

      "io.github.diegopvlk.Cine".Context = {
        filesystems = [ "xdg-videos" ];
        shared = [ "!network" ];
      };

      "io.bassi.Amberol".Context = {
        filesystems = [
          "~/.config/dconf:ro"
          "xdg-music"
        ];
        shared = [ "!network" ];
      };
    };
  };
}
