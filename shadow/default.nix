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

    ./hardware-configuration.nix
    ./disk.nix

    ../modules/nixos/core
    ../modules/nixos/hardware
    ../modules/nixos/networking
    ../modules/nixos/security
    ../modules/nixos/storage
    ../modules/nixos/services
    ../modules/nixos/desktop
    ../modules/nixos/services/flatpak.nix
    ../modules/nixos/gaming/steam.nix
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
