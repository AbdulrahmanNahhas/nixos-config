{ inputs, pkgs, lib, ... }:

{
  # Fix Jovian's 32-bit mangohud double-patching build bug.
  nixpkgs.overlays = [
    inputs.jovian.overlays.default
    (_final: prev: {
      mangohud = prev.mangohud.overrideAttrs (old: {
        patches = lib.unique (old.patches or [ ]);
      });
    })
  ];

  imports = [ inputs.jovian.nixosModules.jovian ];

  jovian = {
    steam = {
      # GNOME stays default. Launch "Gaming Mode" from GDM menu.
      enable = true;

      # Auto-offload Steam and all games to the NVIDIA dGPU in Gaming Mode.
      # Gamescope itself stays on the AMD iGPU to prevent muxless display glitches.
      environment = {
        __NV_PRIME_RENDER_OFFLOAD = "1";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        __VK_LAYER_NV_optimus = "NVIDIA_only";
      };
    };

    # Decky Loader plugins. State persists in /var/lib/decky-loader.
    decky-loader.enable = true;
  };

  # Steam client + GE-Proton tweaks.
  programs.steam = {
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    protontricks.enable = true;
  };

  # On-demand CPU/GPU performance optimizations.
  programs.gamemode.enable = true;

  # Persistent game library on btrfs @saved subvolume.
  systemd.tmpfiles.rules = [
    "d /saved/games 0755 aqua users -"
  ];
}
