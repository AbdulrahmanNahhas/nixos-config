{
  security.sudo.extraConfig = ''
    Defaults env_keep += "EDITOR VISUAL"
  '';

  # Core dumps can contain credentials, decrypted documents, and other process
  # memory. Keep crash diagnostics opt-in instead of persisting them by default.
  systemd.coredump.enable = false;

  # Keep enough encrypted, persistent history to diagnose failures that require
  # booting an older generation, while bounding retained activity tightly.
  services.journald = {
    storage = "persistent";
    extraConfig = ''
      SystemMaxUse=128M
      SystemMaxFileSize=16M
      MaxRetentionSec=7day
    '';
  };
}
