# services.nix
{ pkgs, lib, ... }:
{
  # Core System Controls
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # For Auto Accent Color Extension
  services.desktopManager.gnome.sessionPath = [ pkgs.gjs ];

  # Display & Graphical Environment (SDDM → Niri / GNOME fallback)
  services.xserver.excludePackages = [ pkgs.xterm ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    autoNumlock = true;
    settings = {
      Wayland = {
        EnableHiDPI = "true";
      };
    };
  };
  services.displayManager.defaultSession = "niri";

  # Cursor on hybrid-GPU: hw cursor plane renders on wrong GPU → invisible.
  # WLR_NO_HARDWARE_CURSORS covers Weston, KWIN_FORCE_SW_CURSOR covers kwin_wayland.
  environment.systemPackages = [ pkgs.bibata-cursors ];
  systemd.services.display-manager.environment = {
    WLR_NO_HARDWARE_CURSORS = "1";
    KWIN_FORCE_SW_CURSOR = "1";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "48";
  };

  # qylock: SDDM login theme + Quickshell session lockscreen
  programs.qylock = {
    enable = true;
    theme = "last-of-us";
    sddm.enable = true;
    quickshell.enable = true;
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
