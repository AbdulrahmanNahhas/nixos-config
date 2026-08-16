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

    # Sandboxing
    bubblewrap

    # Coding agent
    codex
  ];
}
