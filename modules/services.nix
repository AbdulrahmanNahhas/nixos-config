# Background services
# (Flatpak remotes + packages live in flatpak.nix — don't re-enable the service here.)
{ ... }:

{
  # ── Power ────────────────────────────────────────────────
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # ── Firmware updates (LVFS) & Thunderbolt security ───────
  # fwupd delivers BIOS/firmware updates; bolt manages Thunderbolt 4 device
  # authorization. Both are standard on a 2025 laptop and have no downside.
  services.fwupd.enable = true;
  services.hardware.bolt.enable = true;

  # ── SSH ──────────────────────────────────────────────────
  services.openssh.enable = true;

  # ── Audio (PipeWire + WirePlumber) ───────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true; # session manager — default-on, spelled out for clarity
  };
  security.rtkit.enable = true;

  # ── SUDO editor passthrough ──────────────────────────────
  security.sudo.extraConfig = ''
    Defaults env_keep += "EDITOR VISUAL"
  '';
}
