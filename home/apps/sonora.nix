{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.sonora.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
