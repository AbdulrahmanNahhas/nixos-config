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

    # Zed's agent requires a non-setuid bwrap on PATH for OS sandboxing.
    bubblewrap
  ];
}
