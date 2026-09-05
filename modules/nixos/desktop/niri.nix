{
  services.displayManager.defaultSession = "niri";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  programs.niri = {
    enable = true;
    # Nautilus is no longer installed, so the portal uses the GTK file chooser.
    useNautilus = false;
  };
}
