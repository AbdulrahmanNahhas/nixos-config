# services.nix
{ pkgs, lib, ... }:
{
  # Core System Controls
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Display & Graphical Environment (GDM + Wayland GNOME)
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.displayManager.gdm = {
    enable = true;
    autoSuspend = false; # Prevents login screen from sleeping your machine
  };
  services.desktopManager.gnome.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gnome-software.enable = false; # Stops background flatpak store indexing

  # Hardware / Local Networks
  services.fwupd.enable = true;
  services.openssh.enable = true;

  # Local Printing Support
  services.printing = {
    enable = true;
    drivers = with pkgs; [ epson-escpr ];
  };

  # Modern Audio Pipeline (Pipewire handles ALSA, Pulse, and Jack natively)
  security.rtkit.enable = true; # Required for pipewire real-time priority
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # Essential for older 32-bit Steam games
    pulse.enable = true;
  };

  # Kavita
  services.kavita = {
    enable = true;
    package = pkgs.kavita;
    dataDir = "/var/lib/kavita";
    user = "kavita";
    tokenKeyFile = "/var/lib/kavita/token_key";
    settings = {
      IpAddresses = "0.0.0.0,::";
      Port = 8083;
    };
  };
  systemd.services.kavita = {
    serviceConfig = {
      BindPaths = [ "/home/aqua/Books:/books" ];
    };
    wantedBy = lib.mkForce [ ];
  };

  # Modern environment hand-off to sudo sessions
  security.sudo.extraConfig = ''
    Defaults env_keep += "EDITOR VISUAL"
  '';
}
