{
  # Memory-safe sudo. Disables the C sudo (the modules assert against each
  # other), so sudoers settings must live under sudo-rs, not security.sudo.
  security.sudo-rs = {
    enable = true;
    extraConfig = ''
      Defaults env_keep += "EDITOR VISUAL"
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
