{ config, pkgs, ... }:
let
  # Flatpak bind-mounts whatever it finds under /usr/share/{fonts,icons} into
  # every sandbox at /run/host/{fonts,share/icons}, independent of the
  # "!host"/"!home" lockdown in services/flatpak.nix. NixOS keeps both in the
  # store, so there was nothing to find and text fell back to the runtime's own
  # fonts (Arabic rendered as tofu). bindfs re-projects them read-only, which
  # also backs the XCURSOR_PATH override in services/flatpak.nix.
  #
  # GTK themes are not covered: flatpak never reads the host's
  # /usr/share/themes. Theme matching needs the org.gtk.Gtk3theme.* extensions
  # installed in services/flatpak.nix.
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
