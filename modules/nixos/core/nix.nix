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
      # Keep a small rollback window while preserving every explicit GC root,
      # including direnv and devenv project environments.
      extraArgs = "--keep 3 --no-gcroots";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
