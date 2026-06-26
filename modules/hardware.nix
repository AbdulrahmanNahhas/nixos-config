# Hardware config (auto-generated base + NVIDIA hybrid graphics)
{
  config,
  lib,
  # pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ── Kernel modules ───────────────────────────────────────
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  # boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # ── NVIDIA + AMD hybrid ──────────────────────────────────
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
  	enable = true;
	enable32Bit = true;
  };

  # hardware.nvidia = {
  	# open = true;
  	# modesetting.enable = true;

	#  package = config.boot.kernelPackages.nvidiaPackages.stable;

	# powerManagement.enable = true;
  	# powerManagement.finegrained = true;

    # prime = {
    #  offload.enable = true;
    #  offload.enableOffloadCmd = true;
    #  amdgpuBusId = "PCI:197:0:0"; # c5:00.0
    #  nvidiaBusId = "PCI:196:0:0"; # c4:00.0
    # };
  # };

  # ── GPU / VA-API env vars ────────────────────────────────
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    NVD_BACKEND = "direct";
    WLR_NO_HARDWARE_CURSORS = "1";
    __GL_SYNC_DISPLAY_DEVICE = "eDP-1";
  };
}
