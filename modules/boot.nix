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
   	# # Black Screen Problem
    # "modeset=1"
    # "module_blacklist=nouveau"

    # NVIDIA DRM/KMS (must pair with hardware.nvidia.modesetting.enable).
    "nvidia_drm.modeset=1"
    "nvidia_drm.fbdev=1"

    # AMD Display Core (RDNA 3.5 requires this).
    "amdgpu.dc=1"

    # Power
    "mem_sleep_default=deep"
    "amd_pstate=active"

    # Fine-grained NVIDIA dynamic power management (D3cold when idle).
    "nvidia.NVreg_DynamicPowerManagement=0x02"
  ];

  boot.blacklistedKernelModules = [
  	"nouveau"
  	"nvidiafb"
  	"rivafb"
  	"rivatv"
  ];
}
