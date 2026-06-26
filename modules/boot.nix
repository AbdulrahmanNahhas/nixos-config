# Bootloader + kernel parameters (systemd-boot)
{ pkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 8;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # boot.initrd.kernelModules = [ "amdgpu" ];

  boot.kernelParams = [
  	# Black Screen Problem
   "modeset=1"
   "module_blacklist=nouveau"

  	# Nvidia DRM/KMS
    "nvidia_drm.modeset=1"
    "nvidia_drm.fbdev=1"

  	# AMD
  	"amdgpu.dc=1"

  	# Power
  	"mem_sleep_default=deep"
  	"amd_pstate=active"

  	# Nvidia runtime D3cold power gate
  	"nvidia.NVreg_DynamicPowerManagement=0x02"
  	# Allow PCIs power maangement to remove power from idle NVIDIA GPU
  	"nvidia.NVreg_EnableGpuFirmware=0"
  ];

  boot.blacklistedKernelModules = [
  	"nouveau"
  	"nvidiafb"
  	"rivafb"
  	"rivatv"
  ];
}
