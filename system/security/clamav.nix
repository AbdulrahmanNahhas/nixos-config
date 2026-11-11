{ pkgs, ... }:
{
  services.clamav = {
    updater.enable = true;
    daemon.enable = false;
    scanner.enable = false;
    clamonacc.enable = false;
  };

  environment.systemPackages = [ pkgs.clamav ];
}
