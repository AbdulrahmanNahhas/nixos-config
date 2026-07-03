{
  inputs,
  pkgs,
  lib,
  username,
  ...
}:
{
  nixpkgs.overlays = [
    # Fix Jovian's 32-bit mangohud double-patching build bug.
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
    })
  ];

  imports = [ inputs.jovian.nixosModules.jovian ];

  jovian.steam = {
    enable = true;
    user = username;
    environment = {
      __NV_PRIME_RENDER_OFFLOAD = "1";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      __VK_LAYER_NV_optimus = "NVIDIA_only";
    };
  };
  jovian.decky-loader.enable = false;

  programs.steam = {
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    protontricks.enable = true;
  };

  programs.gamemode.enable = true;

  systemd.tmpfiles.rules = [
    "d /saved/games 0755 ${username} users -"
  ];
}
