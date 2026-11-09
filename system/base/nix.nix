{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "cgroups"
    ];
    trusted-users = [ "root" ];
    max-jobs = 2;
    cores = 4;

    # Isolate builders for memory-pressure recovery.
    use-cgroups = true;

    # Collect unrooted store paths before a build fills the SSD.
    min-free = 10 * 1024 * 1024 * 1024;
    max-free = 20 * 1024 * 1024 * 1024;

    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  systemd.oomd.enable = true;
  # Leave memory for the desktop on this 16 GiB host.
  systemd.slices.nix-build.sliceConfig = {
    MemoryHigh = "5G";
    MemoryMax = "6G";
    MemorySwapMax = "2G";
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "50%";
  };
  systemd.services.nix-daemon.serviceConfig = {
    Slice = "nix-build.slice";
    Delegate = true;
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
      extraArgs = "--keep 3 --keep-since 3d --no-gcroots";
    };
  };

  # Give interactive work priority over scheduled cleanup.
  systemd.services.nh-clean.serviceConfig = {
    Nice = 19;
    CPUSchedulingPolicy = "idle";
    IOSchedulingClass = "idle";
  };
  # Defer store deduplication on battery; security updates stay scheduled.
  systemd.services.nix-optimise = {
    unitConfig.ConditionACPower = true;
    serviceConfig = {
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };
}
