{
  "com.heroicgameslauncher.hgl".overrides.Context = {
    # Games may still need X11, shared IPC and controller devices.
    sockets = [
      "wayland"
      "x11"
      "pulseaudio"
    ];
    shared = [
      "ipc"
      "network"
    ];
    devices = [ "input" ];
    filesystems = [
      "/run/udev:ro"
      "/saved/games/heroic"
      "~/.steam"
      "xdg-data/Steam"
      "xdg-config/MangoHud:ro"
    ];
  };

  "com.heroicgameslauncher.hgl".overrides."Session Bus Policy"."com.feralinteractive.GameMode" =
    "talk";

  "org.freedesktop.Platform.VulkanLayer.MangoHud" = {
    origin = "flathub";
    # Match Heroic's runtime; review when its runtime branch changes.
    ref = "org.freedesktop.Platform.VulkanLayer.MangoHud//26.08";
    persist = false;
    gpu = false;
  };
}
