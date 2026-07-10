{ config, inputs, ... }:
{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia.enable = true;
  programs.noctalia.systemd.enable = true;

  # Live-editable configuration
  xdg.configFile."noctalia/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/saved/nixos-config/home/aqua/wm/noctalia/config.toml";

  # Immutable asset safe in the Nix store
  xdg.configFile."noctalia-assets/nixos.svg".source = ./nixos.svg;
}
