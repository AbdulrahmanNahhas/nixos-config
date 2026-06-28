{ inputs, pkgs, username, ... }:

let
  # Manual wrapper to run specific work apps on the NVIDIA dGPU
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';

in
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
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  # hardware.acpilight.enable = true;

  # Force desktop environment to stick strictly to AMD iGPU
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    NVD_BACKEND = "direct";
    __GL_SYNC_DISPLAY_DEVICE = "eDP-1";
  };
  services.udev.extraRules = ''
    KERNEL=="card[0-9]", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", ATTRS{vendor}=="0x1002", TAG+="mutter-device-preferred-primary"
  '';

  # ── OpenRazer & Tools ──────────────────────────────────
  hardware.openrazer.enable = true;
  hardware.openrazer.users = [ "${username}" ];

  environment.systemPackages = [
    pkgs.polychromatic
    nvidia-offload # Added wrapper: run `nvidia-offload <app>` in terminal
  ];

  system.stateVersion = "26.05";
}
