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
    "amd_pstate=active"
    "acpi_backlight=native"
    "nvidia_wmi_ec_backlight.force=1"
  ];
}
