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

    # Sandboxing (used by Claude Code's bubblewrap-based agent sandbox)
    bubblewrap
    socat

    # Coding agent
    goose-cli
    goose-desktop
  ];
}
