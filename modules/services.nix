# Background services
{ ... }:

{
  # ── Power ────────────────────────────────────────────────
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # ── Flatpak ──────────────────────────────────────────────
  services.flatpak.enable = true;

  # ── SSH ──────────────────────────────────────────────────
  services.openssh.enable = true;

  # ── Audio (PipeWire) ─────────────────────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # ── SUDO Editor ──────────────────────────────────────────
  security.sudo.extraConfig = ''
    	Defaults env_keep += "EDITOR VISUAL"
  '';
}
