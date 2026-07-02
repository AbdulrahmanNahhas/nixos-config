# graphics.nix
{ config, ... }:
{
  hardware.nvidia = {
    # Diagnostic step: the combo of open kernel modules (mandatory for
    # Blackwell/RTX 50-series) + experimental finegrained runtime PM is a
    # known source of GPU/GSP-firmware hangs on very new hardware.
    # Turning this off keeps the dGPU in low-power idle instead of fully
    # suspending/resuming it on every offload call — costs a little battery,
    # buys a lot of stability. Try this first.
    powerManagement.finegrained = false;

    # Bleeding-edge laptop GPU (RTX 5060 Max-Q / Blackwell) benefits from
    # the newest driver branch rather than "stable", which lags on
    # Blackwell-specific fixes.
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    # Dynamic Boost 2.0 support (Razer explicitly advertises this)
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
