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
          for f in $out/share/wayland-sessions/*.desktop; do
            sed -i 's|^Exec=\(.*\)|Exec=\1 --force-composition|' "$f"
          done
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
