{ ... }:
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
    "org.gnome.World.Secrets"
  ];

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
          # GTK_THEME is deliberately NOT set globally. It is a GTK3-only
          # knob: a GTK4/libadwaita app that sees GTK_THEME=adw-gtk3-dark
          # goes looking for adw-gtk3-dark/gtk-4.0/gtk.css, finds nothing
          # (adw-gtk3 ships gtk-3.0 only) and falls back to *no* stylesheet
          # at all -- unstyled widgets and missing symbolic icons. GTK4 apps
          # already follow the portal's org.gnome.desktop.interface
          # color-scheme, so GTK_THEME is applied per-app to the GTK3
          # holdouts below instead.
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

      "org.libreoffice.LibreOffice" = {
        # LibreOffice's VCL still draws with GTK3, so this is one of the few
        # sandboxes where GTK_THEME is meaningful. The theme files come from
        # the org.gtk.Gtk3theme.adw-gtk3-dark extension installed above.
        Environment.GTK_THEME = "adw-gtk3-dark";

        Context.filesystems = [
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

      "org.signal.Signal" = {
        # Environment is a sibling of Context, not a key inside it -- nested
        # here it was silently written into the [Context] group and never
        # reached the app.
        Environment.ELECTRON_OZONE_PLATFORM_HINT = "wayland";

        Context.filesystems = [ "xdg-download" ];
      };

      # Flatpak has no block-device-only permission. Impression therefore needs
      # the broad device grant from its upstream manifest to flash removable
      # drives; keep this explicit because it is a significant exception.
      "io.gitlab.adhami3310.Impression".Context = {
        devices = [ "all" ];
        filesystems = [
          "~/.config/dconf:ro"
          "xdg-pictures"
        ];
      };

      # --- GTK4 Apps Needing dconf Access ---
      # GTK4 apps using libadwaita need to read org/gnome/desktop/interface
      # dconf settings (especially color-scheme for dark theme support).
      "org.gnome.Fractal".Context = {
        filesystems = [ "~/.config/dconf:ro" ];
      };

      "io.gitlab.news_flash.NewsFlash".Context = {
        filesystems = [ "~/.config/dconf:ro" ];
      };

      "io.github.alainm23.planify".Context = {
        filesystems = [ "~/.config/dconf:ro" ];
      };

      "org.gnome.World.Secrets".Context = {
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
