{
  description = "Shadow - NixOS on Razer Blade 14";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    x-plymouth.url = "github:x-tech-laboratories/X-Plymouth";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Community wrapper for the signed Linux .deb; review wrapper changes on updates.
    codex-desktop-linux = {
      url = "github:ilysenko/codex-desktop-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    delta = {
      url = "github:zed-industries/delta-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
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
      formatter.${system} = pkgs.writeShellApplication {
        name = "nixfmt-all";
        runtimeInputs = [
          pkgs.fd
          pkgs.nixfmt
        ];
        text = ''
          fd --extension nix --exec nixfmt {}
        '';
      };

      devShells.${system}.menu = pkgs.mkShell {
        inputsFrom = [ (import ./home/desktop/menu/rofi-mode.nix { inherit pkgs; }) ];
        packages = [ pkgs.clang-tools ];
        shellHook = ''
          if [ -d home/desktop/menu ]; then
            # clangd reads one argument per line; reuse the build's dependency flags.
            printf '%s\n' -std=c11 -Wall -Wextra \
              -isystem ${pkgs.lib.getDev pkgs.stdenv.cc.libc}/include \
              $(pkg-config --cflags gio-unix-2.0 rofi pangocairo) \
              > home/desktop/menu/compile_flags.txt
          else
            echo 'Run nix develop .#menu from the repository root to refresh clangd flags.'
          fi
        '';
      };

      nixosConfigurations.${host.hostname} = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs;
          inherit (host) hostname username;
        };

        modules = [
          ./configuration.nix
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
