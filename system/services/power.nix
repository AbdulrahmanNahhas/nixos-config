{ ... }:
{
  # PPD owns CPU policy; firmware keeps control of the fans.
  # https://upower.pages.freedesktop.org/power-profiles-daemon/
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Avoid competing power-management daemons.
  services.tlp.enable = false;
  services.auto-cpufreq.enable = false;
  services.tuned.enable = false;
}
