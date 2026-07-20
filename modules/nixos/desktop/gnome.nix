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

  # LocalSearch checks the systemd user-manager environment, but greetd's Niri
  # session records Class=user in logind without importing XDG_SESSION_CLASS.
  # Accept Niri's imported desktop marker as the equivalent real-session guard.
  systemd.user.services.localsearch-3 = {
    overrideStrategy = "asDropin";
    unitConfig.ConditionEnvironment = [
      ""
      "|XDG_SESSION_CLASS=user"
      "|XDG_CURRENT_DESKTOP=niri"
    ];
  };
}
