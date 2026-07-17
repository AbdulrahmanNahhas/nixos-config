{ pkgs, ... }:
{
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ epsonscan2 ];
  };

  services.usbmuxd.enable = false;
}
