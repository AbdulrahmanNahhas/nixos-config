# Bootloader + kernel parameters (systemd-boot)
{ pkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 12;
  };

  boot.kernelPackages = pkgs.linuxPackages;

  boot.initrd.kernelModules = [ "amdgpu" ];

  boot.kernelParams = [
    "nvidia_drm.modeset=1"
    "nvidia_drm.fbdev=1"
    "amdgpu.dc=1"
    "mem_sleep_default=deep"
    "amd_pstate=active"
    "nvidia.NVreg_DynamicPowerManagement=0x02"
  ];

  boot.blacklistedKernelModules = [ "nouveau" ];
}
