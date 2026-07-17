{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # TODO: Reconsider whether all wheel users should have root-equivalent Nix trust.
    trusted-users = [
      "root"
      "@wheel"
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
      extraArgs = "--keep-since 7d --keep 5 --no-direnv";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
