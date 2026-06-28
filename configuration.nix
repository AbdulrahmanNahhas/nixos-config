{
  # config,
  inputs,
  pkgs,
  username,
  ...
}:

{
  imports = [
    # Razer Blade 14 (2025) — owns all NVIDIA/AMD hybrid config
    inputs.nixos-hardware.nixosModules.razer-blade-14-RZ09-0530

    # Auto-generated hardware probe (nixos-generate-config)
    ./hardware-configuration.nix

    # Modules
    ./modules/disko.nix
    ./modules/boot.nix
    ./modules/desktop.nix
    ./modules/packages.nix
    ./modules/flatpak.nix
    ./modules/services.nix
    ./modules/gaming.nix
    ./modules/preservation.nix
    # Home
    ./home.nix
  ];

  # ── Network ──────────────────────────────────────────────
  networking.hostName = "shadow";
  networking.networkmanager.enable = true;

  # ── Locale ───────────────────────────────────────────────
  time.timeZone = "Europe/Istanbul";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── User ─────────────────────────────────────────────────
  # users.mutableUsers = false;
  users.users.root.initialPassword = "changeme";
  users.users.${username} = {
    isNormalUser = true;
    initialPassword = "changeme";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
      "audio"
      "render"
      "gamemode" # lets GameMode switch the CPU governor to `performance`
    ];
    shell = pkgs.fish;
    packages = with pkgs; [ tree ];
  };

  # ── GSConnect (KDE Connect protocol, GNOME-native) ────────────────
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

  # ── Nix / nh ────────────────────────────────────────────
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Allow user to use nix commands and binary caches without sudo
    trusted-users = [
      "root"
      "@wheel"
    ];
  };
  programs.nh = {
    enable = true;
    flake = "/saved/nixos-config";
    clean = {
      enable = true;
      extraArgs = "--keep-since-14d --keep 10";
    };
  };

  # ── Hardware toggles ─────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  hardware.acpilight.enable = true;

  # ── GPU env vars (not covered by nixos-hardware) ────────
  # Hybrid laptop: AMD iGPU drives the panel, NVIDIA dGPU is for
  # Prime render-offload (configured by nixos-hardware).
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi"; # video decode on the AMD iGPU
    NVD_BACKEND = "direct";
    WLR_NO_HARDWARE_CURSORS = "1";
    __GL_SYNC_DISPLAY_DEVICE = "eDP-1";
  };

  # ── OpenRazer ──────────────────────────────────────────
  hardware.openrazer.enable = true;
  hardware.openrazer.users = [ "${username}" ];
  environment.systemPackages = [ pkgs.polychromatic ];

  system.stateVersion = "26.05";
}
