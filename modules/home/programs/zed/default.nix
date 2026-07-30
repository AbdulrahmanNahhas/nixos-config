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

    extensions = [
      "biome"
      "nix"
      "toml"
      "vercel-theme"
      "rainbow-csv"
      "comment"
      "charmed-icons"
      "rich-vesper"
      "rust-and-brown"
    ];
  };
}
