{ pkgs, ... }:
{
  # Standalone desktop applications with no dedicated home-manager `programs.*`
  # module and no natural grouping elsewhere.
  home.packages = with pkgs; [
    obsidian # Notes
    mullvad-browser
  ];
}
