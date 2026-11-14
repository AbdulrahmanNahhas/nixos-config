{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.gpu-screen-recorder
    pkgs.slurp
  ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };

  # jq for Sonora's theme hook.
  systemd.user.services.noctalia.Service.Environment = [
    "PATH=${lib.makeBinPath [ pkgs.jq ]}:${config.home.profileDirectory}/bin:/run/wrappers/bin:/run/current-system/sw/bin"
  ];

  # Read the runtime configuration rendered by sops-nix.
  xdg.configFile."noctalia/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/rendered/noctalia-config.toml";

  xdg.configFile."noctalia-assets/nixos.svg".source = ./nixos.svg;
}
