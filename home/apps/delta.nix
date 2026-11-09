{ inputs, pkgs, ... }:
{
  # The official package includes its CLI wrapper, icon, and desktop entry.
  home.packages = [ inputs.delta.packages.${pkgs.stdenv.hostPlatform.system}.delta ];
}
