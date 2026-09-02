{ pkgs, ... }:
{
  home.packages = [ pkgs.brightnessctl ];

  xdg.configFile."niri/config.kdl".source = ./config.kdl;
  xdg.configFile."niri/binds.kdl".source = ./binds.kdl;
}
