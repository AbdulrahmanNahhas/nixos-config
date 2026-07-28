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

    # Coding agent
    codex
  ];
}
