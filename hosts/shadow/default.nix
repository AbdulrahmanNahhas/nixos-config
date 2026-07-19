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
    inputs.noctalia.nixosModules.default
    inputs.sops-nix.nixosModules.sops

    ./hardware-configuration.nix
    ./disk.nix
    ../../profiles/nixos
    ../../profiles/nixos/desktop.nix
    ../../profiles/nixos/gaming.nix
  ];

  networking.hostName = hostname;
  system.stateVersion = "26.05";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs username; };
    users.${username} = import ../../home/aqua;
  };
}
