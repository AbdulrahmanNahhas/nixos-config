{ config, ... }:
{
  hardware.nvidia = {
    powerManagement.finegrained = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    dynamicBoost.enable = true;
  };

  hardware.graphics.enable = true;

  # Host-specific PCI address; move to shadow/hardware.nix if more facts accumulate.
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", ENV{DEVTYPE}=="drm_minor", ENV{DEVNAME}=="/dev/dri/card[0-9]*", SUBSYSTEMS=="pci", KERNELS=="0000:c5:00.0", TAG+="mutter-device-preferred-primary"
  '';
}
