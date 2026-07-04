{
  inputs,
  pkgs,
  username,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.razer-blade-14-RZ09-0530
    ./hardware-configuration.nix
    ./modules/disko.nix
    ./modules/boot.nix
    ./modules/graphics.nix
    ./modules/desktop.nix
    ./modules/packages.nix
    ./modules/flatpak.nix
    ./modules/services.nix
    ./modules/gaming.nix
    ./modules/preservation.nix
  ];

  networking.hostName = "shadow";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Istanbul";
  i18n.defaultLocale = "en_US.UTF-8";

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
      "gamemode"
      "openrazer"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [ tree ];
  };

  nixpkgs.config.allowUnfree = true;

  # ── Hardware ────────────────────────────────────────────
  # Printer / scanner
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ epsonscan2 ];
  };

  # ── Nix / nh ────────────────────────────────────────────
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
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
  # Modern Developer Environments: automatically loads devenv when entering directories
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ── Misc services ───────────────────────────────────────
  # GSConnect firewall ports
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 1714;
      to = 1764;
    }
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 1714;
      to = 1764;
    }
  ];

  # Kavita
  networking.firewall.allowedTCPPorts = [ 8083 ];

  # Laptop hardware control (Razer Blade lighting / fans via OpenRazer)
  hardware.openrazer = {
    enable = true;
    users = [ "${username}" ];
  };
  environment.systemPackages = with pkgs; [ polychromatic ];

  system.stateVersion = "26.05";
}
