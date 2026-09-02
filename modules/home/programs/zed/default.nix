{ pkgs, ... }:
{
  imports = [
    ./settings.nix
    ./keymaps.nix
    ./languages.nix
    ./lsp.nix
  ];

  programs.zed-editor = {
    enable = true;
    # Zed's GPU selection otherwise picks the discrete NVIDIA card over the
    # AMD 880M (like Brave did before its own override), waking it for plain
    # editing. Hide the NVIDIA Vulkan ICD from Zed so it can only see AMD.
    package = pkgs.zed-editor.fhs.override {
      extraBwrapArgs = [
        "--setenv"
        "VK_ICD_FILENAMES"
        "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
      ];
    };

    extensions = import ./extensions.nix;
  };
}
