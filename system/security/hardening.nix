{ pkgs, username, ... }:
{
  # Keep one sudo implementation.
  security.sudo-rs = {
    enable = true;
    extraConfig = ''
      Defaults env_keep += "EDITOR VISUAL"
    '';
  };

  # Built-in input, Bluetooth and camera; declare permanent approvals here.
  # https://usbguard.github.io/documentation/rule-language.html
  services.usbguard = {
    enable = true;
    IPCAllowedUsers = [
      "root"
      username
    ];
    rules = ''
      allow id 1532:02c5 name "Razer Blade"
      allow id 13d3:3604 name "Wireless_Device"
      allow id 30c9:0104 name "Integrated Camera"
    '';
  };

  # Confinement still requires per-service profiles.
  security.apparmor.enable = true;

  # Disable collection and discard dumps through core_pattern too.
  systemd.coredump.enable = false;
  boot.kernel.sysctl = {
    "kernel.core_pattern" = "|${pkgs.coreutils}/bin/false";

    # Protect group-writable sticky directories from privileged file/FIFO opens.
    "fs.protected_regular" = 2;
    "fs.protected_fifos" = 2;
  };

  # Bound persistent logs for diagnosis across generation rollbacks.
  services.journald.settings.Journal = {
    Storage = "persistent";
    SystemMaxUse = "128M";
    SystemMaxFileSize = "16M";
    MaxRetentionSec = "7day";
  };
}
