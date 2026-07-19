{ config, inputs, ... }:
{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia.enable = true;
  programs.noctalia.systemd.enable = true;

  # sops-nix renders the tracked non-secret template with plugin credentials at
  # activation time. The resulting TOML is writable by Aqua but lives in tmpfs;
  # edit the tracked template for changes that should survive activation.
  xdg.configFile."noctalia/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/rendered/noctalia-config.toml";

  # Immutable asset safe in the Nix store
  xdg.configFile."noctalia-assets/nixos.svg".source = ./nixos.svg;
}
