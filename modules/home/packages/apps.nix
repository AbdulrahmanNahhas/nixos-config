{ pkgs, ... }:
{
  # Standalone desktop applications with no dedicated home-manager `programs.*`
  # module and no natural grouping elsewhere.
  home.packages = with pkgs; [
    obsidian # Notes
    t3code # Web GUI for coding agents
  ];
}
