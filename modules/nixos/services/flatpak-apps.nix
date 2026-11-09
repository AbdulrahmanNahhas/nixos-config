# App IDs are the single source for installation, exceptions, and saved Flatpak data.
{
  "com.heroicgameslauncher.hgl" = {
    overrides.Context = {
      sockets = [
        "wayland"
        "x11"
        "pulseaudio"
      ];
      shared = [
        "ipc"
        "network"
      ];
      devices = [
        "dri"
        "input"
      ];
      filesystems = [
        "/run/udev:ro"
        "/saved/games/heroic"
        # Steam integration
        "/home/aqua/.steam"
        "/home/aqua/.local/share/Steam"
      ];
    };
  };
  "com.github.ADBeveridge.Raider" = { };
  "dev.geopjr.Tuba" = { };
  "io.nahhasio.Linux" = {
    origin = "nahhasio-alpha";
    # The signed reference selects alpha while keeping the catalog key a plain ID.
    flatpakref = "https://github.com/AbdulrahmanNahhas/nahhasio/releases/download/nahhasio-v0.1.1/nahhasio.flatpakref";
    sha256 = "6be1ef3f592e003ea995e45cd4bb8fd7ab8570d7caf484aa8077d22012bfc6b3";
    overrides.Context = {
      sockets = [
        "wayland"
        "pulseaudio"
      ];
      shared = [ "network" ];
      devices = [ "dri" ];
      filesystems = [ "xdg-videos/nahhasio:create" ];
    };
  };
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
  "org.gnome.Fractal" = {
    overrides = {
      Context = {
        # GTK4 requires GPU acceleration for GSK rendering & video media
        devices = [ "dri" ];
      };
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
