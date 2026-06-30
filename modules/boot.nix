{ pkgs, ... }:
{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 8;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.plymouth.enable = false;

  boot.kernelParams = [
    "amdgpu.dc=1"
    "amd_pstate=active"
  ];
  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidiafb"
    "rivafb"
    "rivatv"
    "amdxdna"
  ];

  boot.extraModprobeConfig = ''
    options mt7925e disable_aspm=1
  '';
}
