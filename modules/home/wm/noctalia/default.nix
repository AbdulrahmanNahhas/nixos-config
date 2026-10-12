{ config, ... }:
{
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };

  # Keep your existing sops-nix rendered configuration.
  xdg.configFile."noctalia/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/rendered/noctalia-config.toml";

  # Keep your immutable asset.
  xdg.configFile."noctalia-assets/nixos.svg".source = ./nixos.svg;
}
