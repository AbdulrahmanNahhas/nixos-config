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

  # ── GSConnect Firewall ─────────────────────────────────
  networking.firewall = {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
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

  # ── Hardware & Drivers ─────────────────────────────────
  services.power-profiles-daemon.enable = true;
  nixpkgs.config.allowUnfree = true;
  hardware.bluetooth.enable = true;

  # Hardware acceleration variables (Sync Display strictly removed)
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    NVD_BACKEND = "direct";
  };

  # Force desktop environment (Mutter) to prefer AMD iGPU for rendering
  # but DO NOT ignore NVIDIA, ensuring HDMI hotplugging remains functional.
  services.udev.extraRules = ''
    KERNEL=="card[0-9]", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", ATTRS{vendor}=="0x1002", TAG+="mutter-device-preferred-primary"
  '';

  # ── OpenRazer & Tools ──────────────────────────────────
  hardware.openrazer.enable = true;
  hardware.openrazer.users = [ "${username}" ];

  environment.systemPackages = [
    pkgs.polychromatic
  ];

  system.stateVersion = "26.05";
}
