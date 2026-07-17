{
  description = "Shadow - NixOS on Razer Blade 14";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-flatpak,
      nixos-hardware,
      zen-browser,
      preservation,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      hostname = "shadow";
      username = "aqua";
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };

        modules = [
          ./configuration.nix
          ./home.nix
          inputs.disko.nixosModules.disko
          preservation.nixosModules.default
          home-manager.nixosModules.home-manager
          nix-flatpak.nixosModules.nix-flatpak
          inputs.noctalia.nixosModules.default
        ];
      };
    };
}
