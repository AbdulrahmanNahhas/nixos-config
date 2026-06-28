{ pkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 8;
  };

  # Use the latest kernel for the best support for Strix Point and RTX 50-series
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Plymouth (Beatiful Booting UI)
  boot.plymouth.enable = false;

  boot.kernelParams = [
    # AMD Display Core initialization
    "amdgpu.dc=1"

    # Prevent Strix Point DMCUB firmware panel drop
    "amdgpu.runpm=0"

    # Power Management configurations
    # "mem_sleep_default=deep" # Uses Legacy S3 Sleep
    "amd_pstate=active"
  ];

  # Blacklist conflicting modules
  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidiafb"
    "rivafb"
    "rivatv"
  ];
}
