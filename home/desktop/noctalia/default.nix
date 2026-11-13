{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.gpu-screen-recorder
    pkgs.slurp
  ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };

  # The COSMIC community template generates its theme through a Python hook.
  systemd.user.services.noctalia.Service.Environment = [
    "PATH=${pkgs.python3}/bin:${config.home.profileDirectory}/bin:/run/wrappers/bin:/run/current-system/sw/bin"
  ];

  # Read the runtime configuration rendered by sops-nix.
  xdg.configFile."noctalia/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/rendered/noctalia-config.toml";

  xdg.configFile."noctalia-assets/nixos.svg".source = ./nixos.svg;
}
