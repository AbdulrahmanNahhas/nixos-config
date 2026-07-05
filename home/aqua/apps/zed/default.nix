{ pkgs, ... }:
{
  imports = [
    ./settings.nix
    ./languages.nix
    ./lsp.nix
  ];

  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor.fhs;

    extensions = [
      "nix"
      "toml"
      "vercel-theme"
      "rainbow-csv"
      "comment"
      "charmed-icons"
    ];
  };
}
