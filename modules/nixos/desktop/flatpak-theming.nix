{ config, pkgs, ... }:
let
  # Flatpak unconditionally bind-mounts host fonts and icons/cursors it
  # finds under /usr/share/{fonts,icons} (plus a few ~/.* paths) into every
  # sandbox at /run/host/{fonts,share/icons}, completely independent of the
  # "!host"/"!home" lockdown in services/flatpak.nix. NixOS has no
  # /usr/share/* by default (fonts/icons live in the Nix store instead), so
  # this had nothing to find.
  #
  # This does NOT extend to GTK themes: confirmed live with `flatpak run
  # --command=sh`, a sandbox's own /usr/share/themes only ever contains the
  # runtime's bundled "Default"/"Emacs" themes, regardless of what's bind
  # mounted onto the host's real /usr/share/themes -- flatpak simply never
  # looks there. GTK3 theme matching (e.g. adw-gtk3-dark) instead requires
  # installing the matching org.gtk.Gtk3theme.* flatpak extension; see
  # services/flatpak.nix.
  #
  # bindfs re-projects the relevant packages onto /usr/share read-only so
  # flatpak's existing font/icon exposure mechanism has something to find.
  # This also completes the XCURSOR_PATH override already set in
  # services/flatpak.nix, which points at /run/host/share/icons -- the
  # flatpak-side mirror of /usr/share/icons mounted below.
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
