{ pkgs, ... }:
{
  # Desktop apps without a dedicated Home Manager module.
  home.packages = with pkgs; [
    obsidian
    mullvad-browser
    t3code
  ];
}
