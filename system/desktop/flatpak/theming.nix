{ pkgs, ... }:
{
  # Nixpkgs Flatpak exposes profile fonts/icons and their store dependencies.
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/fl/flatpak/fix-fonts-icons.patch
  fonts.fontDir.enable = true;
  environment.pathsToLink = [ "/share/icons" ];
  environment.systemPackages = with pkgs; [
    morewaita-icon-theme
    adwaita-icon-theme
    hicolor-icon-theme
    bibata-cursors
  ];
}
