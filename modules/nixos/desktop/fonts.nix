{ pkgs, ... }:
{
  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    # Monospace / Developer Fonts
    nerd-fonts.geist-mono
    nerd-fonts.jetbrains-mono

    # English Sans-Serif
    inter
    geist-font

    # Arabic & Multilingual Sans-Serif
    vazirmatn
    ibm-plex # Includes IBM Plex Sans Arabic & IBM Plex Serif

    # High-Quality Arabic & English Serif
    amiri
    noto-fonts # Provides Noto Sans/Naskh Arabic as solid Unicode fallback

    # Emoji
    noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        "Inter"
        "Vazirmatn"
        "IBM Plex Sans Arabic"
        "Noto Sans Arabic"
        "Noto Sans"
      ];
      monospace = [
        "GeistMono Nerd Font"
        "JetBrainsMono Nerd Font"
        "Vazirmatn Code"
        "Noto Sans Arabic"
      ];
      serif = [
        "Amiri"
        "IBM Plex Serif"
        "Noto Serif"
      ];
      emoji = [
        "Noto Color Emoji"
      ];
    };
  };
}
