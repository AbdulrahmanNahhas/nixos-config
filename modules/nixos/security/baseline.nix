{ username, ... }:
{
  # Memory-safe sudo. Disables the C sudo (the modules assert against each
  # other), so sudoers settings must live under sudo-rs, not security.sudo.
  security.sudo-rs = {
    enable = true;
    extraConfig = ''
      Defaults env_keep += "EDITOR VISUAL"
    '';
  };

  # Blocks any USB device not matched below, including ones present at boot.
  # The built-in devices must be listed or the laptop loses its keyboard
  # controller, Bluetooth, and camera. New devices are approved with
  # `usbguard list-devices` / `usbguard allow-device -p <id>`.
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

  # Loads the AppArmor LSM and the profiles shipped by packages that provide
  # them. Nothing here is confined by default; this is the prerequisite for
  # per-service profiles rather than a policy in itself.
  security.apparmor.enable = true;

  # Core dumps can contain credentials, decrypted documents, and other process
  # memory. Keep crash diagnostics opt-in instead of persisting them by default.
  systemd.coredump.enable = false;

  # Keep enough encrypted, persistent history to diagnose failures that require
  # booting an older generation, while bounding retained activity tightly.
  services.journald.settings.Journal = {
    Storage = "persistent";
    SystemMaxUse = "128M";
    SystemMaxFileSize = "16M";
    MaxRetentionSec = "7day";
  };
}
