# boot.nix
{ pkgs, ... }:
{
  # Bootloader Configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 8;
    };

    # Latest kernel for Zen 5 / RTX 50-series support
    kernelPackages = pkgs.linuxPackages_latest;
    # Graphical LUKS prompt and boot progress; Esc still reveals diagnostics.
    plymouth = {
      enable = true;
      theme = "motion";
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ "motion" ];
        })
      ];
    };

    # Modern Performance and Graphics Flags
    kernelParams = [
      "amd_pstate=active"
      "acpi_backlight=native"
      "nvidia_wmi_ec_backlight.force=1"
    ];
  };
}
