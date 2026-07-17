{ pkgs, ... }:
{
  services = {
    desktopManager.gnome = {
      enable = true;
      sessionPath = [ pkgs.gjs ];
    };
    gnome.gnome-keyring.enable = true;
    gnome.gnome-software.enable = false;
    xserver.excludePackages = [ pkgs.xterm ];
  };

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-connections
    gnome-console
    gnome-characters
    yelp
    epiphany
    geary
  ];

  environment.systemPackages = with pkgs; [ gnome-tweaks ];
  programs.seahorse.enable = true;
}
