# App IDs are the single source for installation, exceptions, and saved Flatpak data.
{
  "com.github.ADBeveridge.Raider" = { };
  "dev.geopjr.Tuba" = { };
  "io.gitlab.news_flash.NewsFlash" = {
    overrides = {
      Context.filesystems = [ "~/.config/dconf:ro" ];
    };
  };
  "io.gitlab.theevilskeleton.Upscaler" = {
    overrides = {
      Context = {
        filesystems = [
          "~/.config/dconf:ro"
          "xdg-pictures"
        ];
        shared = [ "!network" ];
      };
    };
  };
  "org.telegram.desktop" = { };
  "io.github.diegopvlk.Cine" = {
    overrides = {
      Context = {
        filesystems = [
          "xdg-videos"
          "xdg-pictures/Cine Screenshots:create"
          "xdg-run/gvfs"
          "xdg-run/gvfsd"
          "xdg-run/pipewire-0:ro"
        ];
        shared = [ "!network" ];
      };
    };
  };
  "io.gitlab.adhami3310.Impression" = {
    overrides = {
      Context = {
        # Image writing is mediated by UDisks2 (upstream's device policy).
        devices = [ "dri" ];
        filesystems = [
          "~/.config/dconf:ro"
          "xdg-pictures"
        ];
      };
    };
  };
  "app.drey.EarTag" = {
    overrides = {
      Context = {
        filesystems = [
          "~/.config/dconf:ro"
          "xdg-music"
          "xdg-download"
        ];
        shared = [ "!network" ];
      };
    };
  };
  "com.jeffser.Nocturne" = {
    overrides = {
      Context = {
        filesystems = [
          "~/.config/dconf:ro"
          "xdg-music"
        ];
        shared = [ "!network" ];
      };
    };
  };
  "moe.tsuna.tsukimi" = {
    overrides = {
      Context.filesystems = [ "~/.config/dconf:ro" ];
    };
  };
  "dev.geopjr.Archives" = { };
  "org.libreoffice.LibreOffice" = {
    overrides = {
      # LibreOffice's VCL still uses GTK3 for this integration.
      Environment.GTK_THEME = "adw-gtk3-dark";
      Context.filesystems = [
        "xdg-documents"
        "xdg-download"
        "xdg-config/fontconfig:ro"
        "xdg-run/gvfsd"
        "~/.local/state/noctalia:ro" # Read-only Noctalia theme state.
      ];
    };
  };
  "io.github.alainm23.planify" = {
    overrides = {
      Context.filesystems = [ "~/.config/dconf:ro" ];
    };
  };
  "org.gnome.World.Secrets" = {
    overrides = {
      Context.filesystems = [ "~/.config/dconf:ro" ];
    };
  };
  "com.github.johnfactotum.Foliate" = {
    overrides.Context.filesystems = [ "xdg-run/speech-dispatcher:ro" ];
  };
  "com.github.jeromerobert.pdfarranger" = {
  };
  "org.gnome.gitlab.YaLTeR.VideoTrimmer" = {
  };
  "org.zotero.Zotero" = {
    overrides = {
      Environment.ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      Context.devices = [ "dri" ]; # GPU-accelerated Electron rendering.
      Context.filesystems = [ "xdg-run/speech-dispatcher:ro" ];
    };
  };
  "com.discordapp.Discord" = {
    overrides = {
      Environment = {
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      };
      Context = {
        # GPU access only; camera support needs a mediated, tested solution.
        devices = [ "dri" ];
        sockets = [ "pulseaudio" ];
        filesystems = [
          "xdg-download"
          "xdg-pictures:ro"
          "xdg-videos:ro"
          "xdg-run/pipewire-0"
        ];
      };
    };
  };
  "org.signal.Signal" = {
    origin = "flathub";
    overrides = {
      Environment.ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      Context = {
        # Do not expose every device for an Electron messenger.
        devices = [ "dri" ];
        sockets = [ "pulseaudio" ];
        filesystems = [ "xdg-download" ];
      };
    };
  };
  "org.b3log.siyuan" = {
    origin = "flathub";
    overrides = {
      Environment.ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      Context.devices = [ "dri" ]; # GPU-accelerated Electron rendering.
      Context.filesystems = [
        "xdg-documents"
        "xdg-desktop"
        "xdg-download"
        "xdg-music:ro"
        "xdg-pictures:ro"
        "xdg-videos:ro"
      ];
    };
  };
  "im.riot.Riot" = {
    origin = "flathub";
    overrides = {
      Environment = {
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        XDG_CURRENT_DESKTOP = "GNOME";
      };
      Context.devices = [ "dri" ]; # GPU-accelerated Electron rendering.
      # Allow Element to use the host GNOME Keyring Secret Service.
      "Session Bus Policy" = {
        "org.freedesktop.secrets" = "talk";
      };
      Context.filesystems = [
        "~/.config/dconf:ro"
        "xdg-run/pipewire-0"
      ];
    };
  };
  "cx.modal.Reflection" = {
    origin = "flathub-beta";
  };
  "org.gtk.Gtk3theme.adw-gtk3" = {
    origin = "flathub";
    persist = false;
  };
  "org.gtk.Gtk3theme.adw-gtk3-dark" = {
    origin = "flathub";
    persist = false;
  };
}
