{ pkgs, ... }:
{
  # Desktop apps without a dedicated Home Manager module.
  home.packages = with pkgs; [
    obsidian # Notes
    mullvad-browser

    anki
    stremio-linux-shell
  ];
}
