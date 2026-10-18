{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Nix development
    deadnix
    nixd
    nixfmt
    statix

    # Git and forge tooling
    gh
    lazygit

    # Sandboxing (used by Zed IDE AI Sandbox)
    # bubblewrap
    # socat
  ];
}
