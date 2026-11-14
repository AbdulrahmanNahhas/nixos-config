{ lib, pkgs, ... }:
{
  # Keep GNOME's screen-sharing backend, but use COSMIC for Open/Save dialogs.
  programs.niri.useNautilus = false;
  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-cosmic ];
    config = {
      niri."org.freedesktop.impl.portal.FileChooser" = lib.mkForce [
        "cosmic"
        "gtk"
      ];
      umbriel."org.freedesktop.impl.portal.FileChooser" = [
        "cosmic"
        "gtk"
      ];
    };
  };

  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  programs.dconf.enable = true;
}
