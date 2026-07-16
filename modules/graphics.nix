# graphics.nix
{ config, ... }:
{
  hardware.nvidia = {
    powerManagement.finegrained = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    dynamicBoost.enable = true;
  };

  # Core Hardware Capabilities
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  # Needed for Steam/Proton — many games still ship 32-bit binaries
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Run Mutter (GNOME) with AMD not NVIDIA
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", ENV{DEVTYPE}=="drm_minor", ENV{DEVNAME}=="/dev/dri/card[0-9]*", SUBSYSTEMS=="pci", KERNELS=="0000:c5:00.0", TAG+="mutter-device-preferred-primary"
  '';
}
