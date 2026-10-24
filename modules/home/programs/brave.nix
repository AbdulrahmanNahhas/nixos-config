{ pkgs, username, ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.brave-origin;

    # Extensions
    extensions = [
      { id = "hlepfoohegkhhmjieoechaddaejaokhf"; } # Refined GitHub
    ];

    # Browser flags
    commandLineArgs = [
      # Load Noctalia theme from local cache
      "--load-extension=/home/${username}/.cache/noctalia/brave-origin-theme"

      # Prefer the selected render node; verify GPU use and sleep on the host.
      "--render-node-override=/dev/dri/renderD128"
      "--ignore-gpu-blocklist"

      # Hardware acceleration
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization,WebRtcPipeWireCamera,OverlayScrollbar,ParallelDownloading"

      # Display
      "--enable-force-dark"
      "--force-color-profile=display-p3-d65"
      "--smooth-scrolling"
    ];
  };
}
