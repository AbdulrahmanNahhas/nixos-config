# Installation, permissions and profile persistence share this catalog.
(import ../../../gaming/flatpak-apps.nix)
// {
  "com.github.ADBeveridge.Raider" = { };
  "com.github.jeromerobert.pdfarranger" = { };
  "dev.geopjr.Tuba" = { };
  "io.nahhasio.Linux" = {
    origin = "nahhasio-alpha";
    # Pin the signed descriptor; installed versions follow the alpha branch.
    flatpakref = "https://github.com/AbdulrahmanNahhas/nahhasio/releases/download/nahhasio-v0.1.1/nahhasio.flatpakref";
    sha256 = "6be1ef3f592e003ea995e45cd4bb8fd7ab8570d7caf484aa8077d22012bfc6b3";
    overrides.Context = {
      sockets = [
        "wayland"
        "pulseaudio"
      ];
      shared = [ "network" ];
      filesystems = [ "xdg-videos/nahhasio:create" ];
    };
  };
  "io.gitlab.news_flash.NewsFlash" = { };
  "io.gitlab.theevilskeleton.Upscaler".overrides.Context = {
    filesystems = [ "xdg-pictures" ];
    shared = [ "!network" ];
  };
  "org.telegram.desktop" = { };
  "io.github.diegopvlk.Cine".overrides.Context = {
    filesystems = [
      "xdg-videos"
      "xdg-pictures/Cine Screenshots:create"
      "xdg-run/gvfs"
      "xdg-run/gvfsd"
      "xdg-run/pipewire-0:ro"
    ];
    shared = [ "!network" ];
  };
  "io.gitlab.adhami3310.Impression".overrides.Context.filesystems = [ "xdg-pictures" ];
  "app.drey.EarTag".overrides.Context = {
    filesystems = [
      "xdg-music"
      "xdg-download"
    ];
    shared = [ "!network" ];
  };

  "org.gnome.World.Secrets" = { };
  "com.github.johnfactotum.Foliate".overrides.Context.filesystems = [
    "xdg-run/speech-dispatcher:ro"
  ];

  "org.gnome.gitlab.YaLTeR.VideoTrimmer" = { };
  "org.signal.Signal" = {
    origin = "flathub";
    # Preserve the existing password-store backend until a migration is rehearsed.
    overrides = {
      Environment.ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      Context = {
        sockets = [ "pulseaudio" ];
        filesystems = [ "xdg-download" ];
      };
    };
  };
  "org.gnome.Fractal" = { };
  "cx.modal.Reflection".origin = "flathub-beta";
  "org.gtk.Gtk3theme.adw-gtk3" = {
    origin = "flathub";
    persist = false;
    gpu = false;
  };
  "org.gtk.Gtk3theme.adw-gtk3-dark" = {
    origin = "flathub";
    persist = false;
    gpu = false;
  };
}
