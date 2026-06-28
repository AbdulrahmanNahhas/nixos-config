# Bootloader + kernel parameters (systemd-boot)
{ pkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 8;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ── Plymouth: smooth initrd → GDM transition (fixes blank screen after LUKS) ──
  boot.plymouth.enable = true;

  # Load amdgpu in initrd for early KMS (nixos-hardware also sets
  # hardware.amdgpu.initrd.enable which covers this, but explicit is safe).
  boot.initrd.kernelModules = [ "amdgpu" ];

  boot.kernelParams = [
    # Black screen fix on this muxless hybrid panel.
    "modeset=1"
    "module_blacklist=nouveau"

    # NVIDIA DRM/KMS (pairs with hardware.nvidia.modesetting.enable from
    # nixos-hardware). fbdev=1 would be wrong here: the eDP panel is wired to
    # the AMD iGPU, not the dGPU.
    "nvidia_drm.modeset=1"

    # AMD Display Core (RDNA 3.5 needs this).
    "amdgpu.dc=1"

    # Keep amdgpu awake: Strix Point DMCUB firmware loses the internal panel
    # across runtime-suspend cycles, breaking eDP detection after pivot_root.
    "amdgpu.runpm=0"

    # Power.
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
