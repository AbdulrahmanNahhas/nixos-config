{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Nix development
    deadnix
    devenv
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
