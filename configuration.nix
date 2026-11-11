{
  inputs,
  hostname,
  username,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.razer-blade-14-RZ09-0530
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.sops-nix.nixosModules.sops

    ./system/base/nix.nix
    ./system/base/users.nix
    ./system/base/locale.nix
    ./system/base/packages.nix

    ./system/hardware/detected.nix
    ./system/hardware/graphics.nix
    ./system/hardware/bluetooth.nix
    ./system/hardware/peripherals.nix
    ./system/hardware/openrazer.nix

    ./system/storage/boot.nix
    ./system/storage/disks.nix
    ./system/storage/persistence.nix
    ./system/storage/maintenance.nix

    ./system/networking/networkmanager.nix
    ./system/networking/dns.nix
    ./system/networking/firewall.nix

    ./system/security/hardening.nix
    ./system/security/clamav.nix
    ./system/security/secrets.nix

    ./system/desktop/umbriel.nix
    ./system/desktop/session.nix
    ./system/desktop/fonts.nix
    ./system/desktop/integration.nix
    ./system/desktop/appimage.nix
    ./gaming/system.nix
    ./system/desktop/flatpak
    ./system/desktop/flatpak/theming.nix

    ./system/services/audio.nix
    ./system/services/power.nix
    ./system/services/ssh.nix
    # ./system/services/bookorbit.nix
  ];

  networking.hostName = hostname;
  system.stateVersion = "26.05";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs username; };
    users.${username} = import ./home.nix;
  };
}
