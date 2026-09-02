{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.brave-origin;

    # Extracted Extensions
    extensions = [
      { id = "hlepfoohegkhhmjieoechaddaejaokhf"; } # Refined GitHub
      { id = "oboonakemofpalcgghocfoadofidjkkk"; } # KeePassXC Browser
    ];

    # Translated brave://flags & GPU Power-Saving Overrides
    commandLineArgs = [
      # Force rendering & video decoding strictly on AMD 880M (Keeps NVIDIA sleeping)
      "--render-node-override=/dev/dri/renderD128"
      "--ignore-gpu-blocklist"

      # Hardware Acceleration & Performance Flags
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization,WebRtcPipeWireCamera,OverlayScrollbar,ParallelDownloading"

      # Display & Visual Flags
      "--enable-force-dark"
      "--force-color-profile=display-p3-d65"
      "--smooth-scrolling"
    ];
  };
}
