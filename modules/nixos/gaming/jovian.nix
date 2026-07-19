{
  inputs,
  lib,
  username,
  ...
}:
{
  imports = [ inputs.jovian.nixosModules.jovian ];

  nixpkgs.overlays = [
    inputs.jovian.overlays.default
    (_final: prev: {
      mangohud = prev.mangohud.overrideAttrs (old: {
        patches = lib.unique (old.patches or [ ]);
      });

      gamescope-session = prev.gamescope-session.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          # In Hybrid/MUX mode eDP-1 is wired to the Radeon 880M. Gamescope's
          # automatic Vulkan selection picks the RTX 5060 first, whose DRM
          # device has no connected outputs, so pin its compositor to AMD.
          substituteInPlace "$out/lib/steamos/gamescope-session" \
            --replace-fail $'exec gamescope \\\n\t--generate-drm-mode fixed' \
            $'exec gamescope \\\n\t--prefer-vk-device 1002:150e \\\n\t--generate-drm-mode fixed'
        '';
      });

      steam = prev.steam.override {
        extraArgs = "-cef-disable-gpu-compositing";
      };
    })
  ];

  jovian.steam = {
    enable = true;
    user = username;
  };
  # The internal panel is wired to the Radeon in Hybrid/MUX mode.  Do not
  # offload the Gamescope compositor itself: it needs the GPU that owns eDP-1.
  # To wake and use NVIDIA for an individual Steam game, set its launch option
  # to `nvidia-offload %command%` in Steam's Properties > General.
  # This is a Razer laptop, not Steam Deck hardware. In particular, Jovian's
  # SteamOS command line disables the IOMMU, which prevents the AMD XDNA/NPU
  # driver from loading and weakens DMA isolation.
  jovian.steamos.enableDefaultCmdlineConfig = false;
  jovian.decky-loader.enable = false;
}
