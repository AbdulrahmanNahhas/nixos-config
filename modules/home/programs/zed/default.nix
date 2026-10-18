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
    # Zed's GPU selection otherwise picks the discrete NVIDIA card over the AMD 880M
    package = pkgs.zed-editor.fhs.override {
      extraBwrapArgs = [
        "--setenv"
        "VK_ICD_FILENAMES"
        "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
      ];
    };
  };
}
