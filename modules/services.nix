# Background services
{ pkgs, ... }:
{
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  # services.logind.settings.Login = {
  #   # HandleSuspendKey = "ignore";
  #   # HandleHibernateKey = "ignore";
  #   # HandlePowerKey = "ignore";
  #   LidSwitch = "ignore";
  #   LidSwitchDocked = "ignore";
  #   LidSwitchExternalPower = "ignore";
  # };
  services.xserver.excludePackages = [ pkgs.xterm ];

  services.xserver.enable = true;
  services.displayManager.gdm = {
    enable = true;
    autoSuspend = false;
  };
  services.desktopManager.gnome.enable = true;

  services.gnome.gnome-keyring.enable = true;
  services.gnome.gnome-software.enable = false;

  services.fwupd.enable = true;
  services.hardware.bolt.enable = true;

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      epson-escpr
    ];
  };

  services.openssh.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  security.rtkit.enable = true;

  security.sudo.extraConfig = ''
    Defaults env_keep += "EDITOR VISUAL"
  '';
}
