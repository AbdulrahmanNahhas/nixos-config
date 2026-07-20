{
  programs.niri.enable = true;
  services.displayManager.defaultSession = "niri";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    # niri-session imports this into the systemd user manager. LocalSearch
    # requires a real user session before it will index GNOME Music content.
    XDG_SESSION_CLASS = "user";
  };
}
