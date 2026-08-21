{ pkgs, ... }:
{
  imports = [
    ./settings.nix
    ./keymaps.nix
    ./languages.nix
    ./lsp.nix
  ];

  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor.fhs;

    extensions = import ./extensions.nix;
  };
}
