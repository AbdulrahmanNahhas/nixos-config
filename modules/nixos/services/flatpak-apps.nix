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
    strictFilesystems = true;
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
    strictFilesystems = true;
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
        devices = [ "all" ];
        filesystems = [
          "~/.config/dconf:ro"
          "xdg-pictures"
        ];
      };
    };
  };
  "app.drey.EarTag" = {
    strictFilesystems = true;
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
    strictFilesystems = true;
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
  };
  "com.github.jeromerobert.pdfarranger" = {
  };
  "org.gnome.gitlab.YaLTeR.VideoTrimmer" = {
  };
  "org.zotero.Zotero" = {
    overrides = {
      Environment.ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      Context.devices = [ "dri" ]; # GPU-accelerated Electron rendering.
    };
  };
  "com.discordapp.Discord" = {
    overrides = {
      Environment = {
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      };
      Context = {
        # "dri" provides GPU acceleration. Change to [ "all" ] if you use a webcam for video calls.
        devices = [ "dri" ];
        sockets = [ "pulseaudio" ];
        filesystems = [ "xdg-download" ];
      };
    };
  };
  "org.signal.Signal" = {
    origin = "flathub";
    overrides = {
      Environment.ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      Context = {
        devices = [ "all" ];
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
