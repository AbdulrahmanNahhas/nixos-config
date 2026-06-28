{ pkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 8;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # TEST: Temporarily disable Plymouth if the black screen persists.
  # Plymouth frequently hangs during the GDM handoff on hybrid layouts.
  # boot.plymouth.enable = false;

  # Force AMD iGPU drivers to load inside initrd for early KMS
  boot.initrd.kernelModules = [ "amdgpu" ];

  boot.kernelParams = [
    # "modeset=1"
    # "module_blacklist=nouveau"

    # NVIDIA DRM/KMS configuration (paired with nixos-hardware)
    "nvidia_drm.modeset=1"

    # AMD Display Core initialization
    "amdgpu.dc=1"

    # Prevent Strix Point DMCUB firmware panel drop bugs across power cycles
    "amdgpu.runpm=0"

    # Power Management configurations
    "mem_sleep_default=deep"
    "amd_pstate=active"

    # Force NVIDIA dGPU into D3cold state when idle
    "nvidia.NVreg_DynamicPowerManagement=0x02"
  ];

  # Block open-source Nouveau drivers to prevent conflicts with proprietary NVIDIA
  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidiafb"
    "rivafb"
    "rivatv"
  ];
}
