{
  security.sudo.extraConfig = ''
    Defaults env_keep += "EDITOR VISUAL"
  '';

  # Core dumps can contain credentials, decrypted documents, and other process
  # memory. Keep crash diagnostics opt-in instead of persisting them by default.
  systemd.coredump.enable = false;

  # Root is tmpfs, so keep the journal bounded and ephemeral as well. Important
  # failures remain available for the current boot without retaining activity
  # history indefinitely on /saved.
  services.journald = {
    storage = "volatile";
    extraConfig = ''
      RuntimeMaxUse=128M
      RuntimeMaxFileSize=16M
      MaxRetentionSec=7day
    '';
  };
}
