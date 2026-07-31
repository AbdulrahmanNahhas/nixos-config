{ pkgs, ... }:
{
  home.packages = with pkgs; [
    obsidian
    plezy
    t3code
  ];
}
