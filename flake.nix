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

    preservation = {
      url = "github:nix-community/preservation";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-flatpak,
      nixos-hardware,
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
        ];
      };
    };
}
