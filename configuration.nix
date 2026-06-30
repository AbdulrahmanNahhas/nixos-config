{ inputs, pkgs, username, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.razer-blade-14-RZ09-0530
    ./hardware-configuration.nix
    ./modules/disko.nix
    ./modules/boot.nix
    ./modules/desktop.nix
    ./modules/packages.nix
    ./modules/flatpak.nix
    ./modules/services.nix
    ./modules/gaming.nix
    ./modules/preservation.nix
    ./home.nix
  ];

  # ── Network & Locale ───────────────────────────────────
  networking.hostName = "shadow";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Istanbul";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── User Configuration ─────────────────────────────────
  users.users.root.initialPassword = "changeme";
  users.users.${username} = {
    isNormalUser = true;
    initialPassword = "changeme";
    extraGroups = [ "wheel" "networkmanager" "video" "input" "audio" "render" "gamemode" ];
    shell = pkgs.fish;
    packages = with pkgs; [ tree ];
  };

  # ── Hardware & Drivers ─────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  hardware.bluetooth.enable = true;
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    NVD_BACKEND = "direct";
  };

  # Printer
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      epsonscan2
    ];
  };

  # ── Nix / nh Package Manager ───────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
  };
  programs.nh = {
    enable = true;
    flake = "/saved/nixos-config";
    clean = {
      enable = true;
      extraArgs = "--keep-since-14d --keep 10";
    };
  };

  # ── GSConnect Firewall ─────────────────────────────────
  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
  ];
  };

  # ── OpenRazer & Tools ──────────────────────────────────
  hardware.openrazer.enable = true;
  hardware.openrazer.users = [ "${username}" ];
  environment.systemPackages = with pkgs; [
    polychromatic
  ];

  system.stateVersion = "26.05";
}
