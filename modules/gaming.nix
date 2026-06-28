# Gaming — Steam Deck "Gaming Mode" (Jovian) + Proton GE + Decky + GameMode.
#
# NVIDIA/PRIME offload, bus IDs, modesetting and power management are owned by
# the nixos-hardware Razer Blade 14 module — not duplicated here. Desktop/work
# runs on the AMD iGPU (GNOME stays the default GDM session); the dGPU is only
# engaged inside Gaming Mode via the PRIME env vars below.
{ inputs, pkgs, ... }:

{
  # Jovian overlay: gamescope-session, steamos-manager, decky-loader,
  # gamescope-wsi, scx schedulers, etc.
  nixpkgs.overlays = [ inputs.jovian.overlays.default ];

  imports = [ inputs.jovian.nixosModules.jovian ];

  jovian = {
    steam = {
      # Registers a "Gaming Mode" (gamescope) session in GDM. autoStart is
      # intentionally off — GNOME stays default for daily work; pick Gaming
      # Mode from the GDM gear menu to play.
      enable = true;

      # Render games on the NVIDIA dGPU via PRIME offload (nixos-hardware
      # already set up offload + the `nvidia-offload` wrapper). The dGPU
      # renders; frames present to the AMD-driven panel. If a game fails to
      # launch in Gaming Mode, drop this block and use
      # `nvidia-offload %command%` per-game from desktop Steam instead.
      environment = {
        __NV_PRIME_RENDER_OFFLOAD = "1";
        __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        __VK_LAYER_NV_optimus = "NVIDIA_only";
      };
    };

    # Decky Loader → Decky store (CSSLoader/DeckThemes, AudioLoader,
    # PowerTools, ...). State in /var/lib/decky-loader (persisted).
    decky-loader.enable = true;
  };

  # Steam (desktop client + 32-bit libs) + latest GE-Proton.
  # jovian.steam.enable already sets programs.steam.enable = mkDefault true.
  programs.steam = {
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ]; # auto-updated with nixpkgs
    protontricks.enable = true; # fixes/inspects Proton prefixes
  };

  # GameMode: on-demand CPU governor → performance, renice, ioprio, GPU opts.
  # Use `gamemoderun %command%` in desktop Steam launch options. The aqua user
  # is added to the `gamemode` group in configuration.nix so the governor can
  # actually switch.
  programs.gamemode.enable = true;
}
