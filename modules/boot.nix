{ pkgs, ... }:
{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 8;
  };

  # Latest kernel recommended by nixos-hardware for MT7925 WiFi stability
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.plymouth.enable = false;

  boot.kernelParams = [
    "amd_pstate=active"   # AMD active P-state CPU frequency scaling
  ];

  # Block drivers we don't want (nouveau = community NV, nvidiafb = console
  # framebuffer on NV, amdxdna = NPU, currently problematic on this SoC)
  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidiafb"
    "amdxdna"
  ];
}