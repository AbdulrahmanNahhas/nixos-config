{ ... }:
let
  flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  flathub_beta = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";

  # Apps available from Flathub's publisher-verified subset.
  verifiedApps = [
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
    "com.github.johnfactotum.Foliate"
    "com.github.jeromerobert.pdfarranger"
    "org.gnome.gitlab.YaLTeR.VideoTrimmer"
    "org.zotero.Zotero"
  ];

  # Community-maintained, not currently publisher-verified by Flathub.
  unverifiedApps = [
    "org.signal.Signal"
    "org.b3log.siyuan"
  ];

  betaApps = [
    "cx.modal.Reflection"
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
      {
        name = "flathub-beta";
        location = flathub_beta;
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
      }) (unverifiedApps ++ gtkThemeExtensions)
      ++ map (appId: {
        inherit appId;
        origin = "flathub-beta";
      }) betaApps;

    # Flatpaks track Flathub, not the NixOS channel, so they need their own timer.
    update = {
      onActivation = false;
      auto = {
        enable = true;
        onCalendar = "daily";
      };
    };

    # This file is the source of truth for installed Flatpaks.
    uninstallUnmanaged = true;
    uninstallUnused = true;

    overrides = {
      # Nix fully owns the override files: manual `flatpak override` edits are
      # discarded on activation, and removed apps lose their override file too.
      # Without this the sandbox policy below is advisory, not authoritative.
      writeMode = "replace";
      pruneUnmanagedOverrides = true;

      settings = {
        # Every app starts fully restricted and is granted back only what it
        # needs. Anything not listed below runs with this baseline alone.
        global = {
          Environment = {
            # Flatpak already bind-mounts host icon themes read-only at
            # /run/host; this only points the cursor loader at them.
            XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";

            # GTK_THEME is deliberately not global: it is GTK3-only, and a
            # GTK4/libadwaita app that sees it looks for a gtk-4.0 stylesheet
            # adw-gtk3 does not ship and ends up with none at all. GTK4 apps
            # already follow the portal, so it is set per-app below instead.
          };

          Context = {
            # No host filesystem or real home. Files still reach apps through
            # the file portal, which grants per-file access on user consent.
            filesystems = [
              "!host"
              "!home"

              # Read-only access to GTK 3 & 4 user configurations
              "xdg-config/gtk-3.0:ro"
              "xdg-config/gtk-4.0:ro"
            ];

            # Wayland only. Audio stays under each upstream manifest because
            # Flatpak's PulseAudio socket is also the PipeWire compat path.
            sockets = [
              "wayland"
              "!x11"
              "!fallback-x11"
            ];

            # Drop the broad device access most manifests request.
            devices = [ "!all" ];

            # Wayland apps do not need the shared IPC namespace X11 requires.
            shared = [ "!ipc" ];
          };
        };

        # --- Exceptions & app-specific routing -----------------------------

        # Private knowledge base. Its manifest --persist entries keep the
        # workspace inside ~/.var/app, so the global !home policy costs nothing
        # and the data is covered by preservation's .var/app loop.
        "org.b3log.siyuan" = {
          Environment.ELECTRON_OZONE_PLATFORM_HINT = "wayland";
          Context.devices = [ "dri" ]; # GPU-accelerated Electron rendering.
        };

        # Upstream requests device=all for camera access during calls; Signal
        # uses /dev/video* directly rather than the camera portal.
        "org.signal.Signal" = {
          Environment.ELECTRON_OZONE_PLATFORM_HINT = "wayland";
          Context = {
            devices = [ "all" ];
            sockets = [ "pulseaudio" ];
            filesystems = [ "xdg-download" ];
          };
        };

        "com.brave.Browser".Context.filesystems = [ "xdg-download" ];

        "org.libreoffice.LibreOffice" = {
          # LibreOffice's VCL still uses GTK3 for this integration.
          Environment.GTK_THEME = "adw-gtk3-dark";
          Context.filesystems = [
            "xdg-documents"
            "xdg-download"
            "~/.local/state/noctalia:ro" # Read-only Noctalia theme state.
          ];
        };

        # Writes bootable images to removable media. Replace `all` with `usb`
        # if a future release works without full device access.
        "io.gitlab.adhami3310.Impression".Context = {
          devices = [ "all" ];
          filesystems = [
            "~/.config/dconf:ro"
            "xdg-pictures"
          ];
        };

        # --- Read-only dconf for apps that follow interface preferences -----

        "org.gnome.Fractal".Context.filesystems = [ "~/.config/dconf:ro" ];
        "io.gitlab.news_flash.NewsFlash".Context.filesystems = [ "~/.config/dconf:ro" ];
        "io.github.alainm23.planify".Context.filesystems = [ "~/.config/dconf:ro" ];
        "org.gnome.World.Secrets".Context.filesystems = [ "~/.config/dconf:ro" ];
        "moe.tsuna.tsukimi".Context.filesystems = [ "~/.config/dconf:ro" ];

        # --- Local-only apps: no reason to reach the network ----------------

        "io.gitlab.theevilskeleton.Upscaler".Context = {
          filesystems = [
            "~/.config/dconf:ro"
            "xdg-pictures"
          ];
          shared = [ "!network" ];
        };

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
  };
}
