{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Only root is trusted. A trusted user can push arbitrary paths into the
    # store and is effectively root; rebuilds go through the daemon anyway.
    trusted-users = [ "root" ];

    # Declared system-wide so untrusted users still get cache hits. A
    # non-trusted user cannot add these at runtime, which would otherwise make
    # every devenv shell build from source.
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  nix.optimise = {
    automatic = true;
    dates = [ "Fri 04:00" ];
  };

  programs.nh = {
    enable = true;
    flake = "/saved/nixos-config";
    clean = {
      enable = true;
      dates = "Fri 03:00";
      extraArgs = "--keep 3 --keep-since 7d --no-gcroots";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Espressif's Xtensa Rust toolchain is distributed as generic Linux
  # binaries. nix-ld provides its expected ELF loader on NixOS.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
    ];
  };
}
