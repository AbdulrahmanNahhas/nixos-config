# Bootloader + kernel parameters (systemd-boot)
{ pkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 8;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Load amdgpu in initrd for early KMS (nixos-hardware also sets
  # hardware.amdgpu.initrd.enable which covers this, but explicit is safe).
  boot.initrd.kernelModules = [ "amdgpu" ];

  boot.kernelParams = [
   	# # Black Screen Problem
    # "modeset=1"
    # "module_blacklist=nouveau"

    # NVIDIA DRM/KMS (must pair with hardware.nvidia.modesetting.enable).
    # fbdev=1 is harmful on muxless hybrid: the NVIDIA dGPU has no
    # physical panel — the eDP panel is wired to the AMD iGPU.
    "nvidia_drm.modeset=1"

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
