{ config, pkgs, ... }:
let
  # Project Nix fonts/icons read-only into /usr/share for Flatpak discovery.
  # GTK themes need separate org.gtk.Gtk3theme extensions in services/flatpak.nix.
  aggregatedFonts = pkgs.buildEnv {
    name = "flatpak-shared-fonts";
    paths = config.fonts.packages;
    pathsToLink = [ "/share/fonts" ];
  };

  aggregatedIcons = pkgs.buildEnv {
    name = "flatpak-shared-icons";
    paths = with pkgs; [
      morewaita-icon-theme
      adwaita-icon-theme
      hicolor-icon-theme
      bibata-cursors
    ];
    pathsToLink = [ "/share/icons" ];
  };

  mkRoBind = source: {
    device = source;
    fsType = "fuse.bindfs";
    options = [
      "ro"
      "resolve-symlinks"
      "fsname=hostfsBind"
    ];
  };
in
{
  system.fsPackages = [ pkgs.bindfs ];

  fileSystems = {
    "/usr/share/fonts" = mkRoBind "${aggregatedFonts}/share/fonts";
    "/usr/share/icons" = mkRoBind "${aggregatedIcons}/share/icons";
  };
}
