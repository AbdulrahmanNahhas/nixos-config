{ pkgs, ... }:
{
  services = {
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true; # Trash and network mounts for GTK applications
  };
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    nautilus
    loupe
    papers
    resources
    gnome-disk-utility
  ];
}
