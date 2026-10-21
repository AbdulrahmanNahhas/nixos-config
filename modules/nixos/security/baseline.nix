{ pkgs, username, ... }:
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
  # controller, Bluetooth, and camera. Inspect with `usbguard list-devices`;
  # `allow-device <id>` is temporary. Permanent approvals belong in rules
  # below: NixOS supplies an immutable policy, so IPC cannot write it with -p.
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

  # Disabling systemd-coredump alone falls back to a `core` file in the
  # crashing process's working directory. Discard the kernel's dump stream
  # too, so a crash cannot write credentials or decrypted documents to disk.
  systemd.coredump.enable = false;
  boot.kernel.sysctl = {
    "kernel.core_pattern" = "|${pkgs.coreutils}/bin/false";

    # Extend the kernel's sticky-directory file/FIFO protections to group-
    # writable directories too; prevent privileged opens of another user's file.
    "fs.protected_regular" = 2;
    "fs.protected_fifos" = 2;
  };

  # Keep enough encrypted, persistent history to diagnose failures that require
  # booting an older generation, while bounding retained activity tightly.
  services.journald.settings.Journal = {
    Storage = "persistent";
    SystemMaxUse = "128M";
    SystemMaxFileSize = "16M";
    MaxRetentionSec = "7day";
  };
}
