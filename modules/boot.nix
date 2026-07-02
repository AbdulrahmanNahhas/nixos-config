# boot.nix
{ pkgs, ... }:
{
  # Bootloader Configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 8;
  };

  # Latest kernel for Zen 5 / RTX 50-series support
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.plymouth.enable = false;

  # Modern Performance and Graphics Flags
  boot.kernelParams = [
    "amd_pstate=active"    # Forces autonomous EPP frequency tuning for Zen 5
    "acpi_backlight=native"
    # "nvidia-drm.fbdev=1"   # Hands off the framebuffer smoothly to GDM/Wayland
  ];
}
