# Gaming — Steam Deck "Gaming Mode" UI (Jovian) + Proton GE + Decky + GameMode.
#
# NVIDIA/PRIME offload, bus IDs, modesetting and power management are all owned
# by the nixos-hardware Razer Blade 14 module — NOT duplicated here. This module
# only layers on the Steam Deck experience, compatibility tools and per-game
# performance helpers. Desktop/work uses the AMD iGPU (GNOME stays the default
# session); the dGPU is engaged only inside the Gaming Mode session via the
# PRIME offload env vars below.
{ inputs, pkgs, ... }:

{
  # ── Jovian NixOS overlay (provides gamescope-session, steamos-manager,
  #    decky-loader, gamescope-wsi, scx schedulers, …) ────────────────────
  nixpkgs.overlays = [ inputs.jovian.overlays.default ];

  imports = [
    inputs.jovian.nixosModules.jovian
  ];

  jovian = {
    steam = {
      # Adds the "Gaming Mode" (gamescope) session to GDM. We deliberately do
      # NOT set autoStart — that would replace GDM/GNOME with SDDM and boot
      # straight into Gaming Mode. GNOME remains the default for daily work;
      # pick "Gaming Mode" from the GDM gear menu when you want to play.
      enable = true;

      # Force the gamescope session to render on the NVIDIA dGPU through PRIME
      # offload (nixos-hardware already set up offload + the `nvidia-offload`
      # wrapper). The dGPU renders, frames are presented to the AMD-driven
      # panel via PRIME. If a game fails to launch under Gaming Mode, try
      # removing this block and using `nvidia-offload %command%` per-game from
      # desktop Steam instead.
      environment = {
        __NV_PRIME_RENDER_OFFLOAD = "1";
        __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        __VK_LAYER_NV_optimus = "NVIDIA_only";
      };
    };

    # Decky Loader — the plugin loader for the Steam Deck UI. Enables the Decky
    # store (CSSLoader/DeckThemes, AudioLoader, PowerTools, etc.). State lives
    # in /var/lib/decky-loader (persisted in preservation.nix).
    decky-loader.enable = true;
  };

  # ── Steam (desktop client + 32-bit libs) + Proton GE ───────────────────
  # jovian.steam.enable already sets programs.steam.enable = mkDefault true;
  # we extend it with the latest GE-Proton and open the Remote Play firewall.
  programs.steam = {
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin # latest GE-Proton, auto-updated with nixpkgs
    ];
    protontricks.enable = true; # handy for fixing Proton prefixes
  };

  # ── GameMode: on-demand CPU governor / renice / ioprio / GPU optimizations ─
  # Launch a game with `gamemoderun %command%` (desktop Steam launch options).
  # The aqua user is added to the `gamemode` group in configuration.nix so the
  # CPU governor can actually be switched to `performance`.
  programs.gamemode.enable = true;
}
