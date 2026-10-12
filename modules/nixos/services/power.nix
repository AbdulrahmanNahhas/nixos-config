{ ... }:
{
  # Noctalia selects profiles through PPD; UPower supplies battery status.
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Avoid competing power-management daemons.
  services.tlp.enable = false;
  services.auto-cpufreq.enable = false;

  # NVMe SSD maintenance.
  services.fstrim.enable = true;
}
