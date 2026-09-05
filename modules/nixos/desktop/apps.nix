{ pkgs, ... }:
{
  services = {
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true; # Trash and network mounts for GTK applications
  };
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    cosmic-edit
    cosmic-files
    cosmic-monitor
    cosmic-player
    cosmic-reader
    cosmic-viewer

    gnome-disk-utility
    papers
  ];
}
