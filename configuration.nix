{
  # config,
  # lib,
  pkgs,
  username,
  ...
}:

{
  imports = [
    ./modules/hardware.nix
    ./modules/disko.nix
    ./modules/boot.nix
    ./modules/desktop.nix
    ./modules/packages.nix
    ./modules/flatpak.nix
    ./modules/services.nix
    ./modules/preservation.nix
    # ./modules/specialisation.nix
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
    ];
    shell = pkgs.fish;
    packages = with pkgs; [ tree ];
  };

  # --- KDE Connect --------------------------------------------------
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };
  networking.firewall = {
    allowedTCPPortRanges = [ {from = 1714; to = 1764; }];
    allowedUDPPortRanges = [ {from = 1714; to = 1764; }];
  };

  # ── Nix / nh ─────────────────────────────────────────────
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  programs.nh = {
    enable = true;
    # The flake lives on the persistent /saved subvolume (tmpfs root wipes
    # /etc on every reboot, so /etc/nixos is not a safe place for it).
    flake = "/saved/nixos-config";
    clean = {
      enable = true;
      extraArgs = "--keep-since-14d --keep 10";
    };
  };

  # ── Hardware toggles ─────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  hardware.acpilight.enable = true;

  system.stateVersion = "26.05";
}
