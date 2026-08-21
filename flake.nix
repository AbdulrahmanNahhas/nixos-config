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
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    goose = {
      url = "github:aaif-goose/goose";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";

      host = {
        hostname = "shadow";
        username = "aqua";
      };

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      formatter.${system} = pkgs.nixfmt-rfc-style;

      nixosConfigurations.${host.hostname} = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs;
          inherit (host) hostname username;
        };

        modules = [
          ./${host.hostname}
        ];
      };

      checks.${system}.gitleaks =
        pkgs.runCommand "gitleaks-check"
          {
            nativeBuildInputs = [ pkgs.gitleaks ];
          }
          ''
            gitleaks dir \
              --no-banner \
              --redact \
              ${self}

            touch $out
          '';
    };
}
