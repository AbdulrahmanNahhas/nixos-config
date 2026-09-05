{ lib, ... }:
{
  services.displayManager.defaultSession = "niri";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  programs.niri = {
    enable = true;
    # Route file selection through xdg-desktop-portal-gtk instead of Nautilus.
    useNautilus = false;
  };

  # Without Nautilus, GNOME's portal delegates FileChooser to a service that is
  # not installed. Prefer GTK while retaining GNOME for interfaces GTK lacks.
  xdg.portal.config.niri.default = lib.mkForce [
    "gtk"
    "gnome"
  ];
}
