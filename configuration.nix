{ inputs, pkgs, lib, username, ... }:
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

  networking.hostName = "shadow";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Istanbul";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.root.initialPassword = "changeme";
  users.users.${username} = {
    isNormalUser = true;
    initialPassword = "changeme";
    extraGroups = [ "wheel" "networkmanager" "video" "input" "audio" "render" "gamemode" ];
    shell = pkgs.fish;
    packages = with pkgs; [ tree ];
  };

  # ── Hardware ────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  hardware.bluetooth.enable = true;

  # AMD iGPU drives the panel by default; NVIDIA dGPU is available via
  # `nvidia-offload <cmd>` or the Jovian Steam session, otherwise held in
  # runtime D3. The `battery-saver` boot specialisation unloads NVIDIA
  # entirely (modules blacklisted, PCI devices removed) for max battery
  # during pure work/study sessions.
  hardware.nvidia.primeBatterySaverSpecialisation = true;
  # Patch nixos-hardware's specialisation: it forces offload off but leaves
  # enableOffloadCmd on (set as mkDefault by the razer module), which trips
  # the NixOS NVIDIA assertion ("Offload command requires offloading…").
  specialisation.battery-saver.configuration.hardware.nvidia.prime.offload.enableOffloadCmd = lib.mkForce false;

  # Printer / scanner
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ epsonscan2 ];
  };

  # ── Nix / nh ────────────────────────────────────────────
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

  # ── Misc services ───────────────────────────────────────
  # GSConnect firewall ports
  networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];

  # Laptop hardware control (Razer Blade lighting / fans via OpenRazer)
  hardware.openrazer.enable = true;
  hardware.openrazer.users = [ "${username}" ];
  environment.systemPackages = with pkgs; [ polychromatic ];

  system.stateVersion = "26.05";
}