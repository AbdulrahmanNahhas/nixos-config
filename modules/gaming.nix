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

      # 1. PREVENT "BLACK WINDOW" BUG: Disables GPU compositing in Steam's
      # CEF browser interface to prevent Nvidia/XWayland rendering bugs.
      steam = prev.steam.override {
        extraArgs = "-cef-disable-gpu-compositing";
      };
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

  # 2. ENABLE XWAYLAND: Ensures the system-wide XWayland packages are ready.
  programs.xwayland.enable = true;

  # 3. ADD XWAYLAND-SATELLITE: Niri will automatically detect this in your
  # PATH and spin it up on-demand when Steam tries to launch.
  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];
}
