{
  programs.niri.enable = true;
  services.displayManager.defaultSession = "niri";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    # Ensure user services and portals see a normal interactive session when
    # Niri is launched through greetd.
    XDG_SESSION_CLASS = "user";
  };
}
