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

  # 16 GiB RAM and 20 CPU threads: the defaults allow 20 simultaneous builds,
  # each told to use every core. Leave headroom for the desktop and dev tools.
  # Builders that ignore NIX_BUILD_CORES still need workload-specific limits.
  nix.settings = {
    max-jobs = 2;
    cores = 4;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs username; };
    users.${username} = import ./home.nix;
  };
}
