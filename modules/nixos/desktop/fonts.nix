{ pkgs, ... }:
{
  # Expose fonts to Flatpak through desktop/flatpak-theming.nix.
  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    # Provide the Adwaita fonts named by desktop/dconf.nix; avoid fallback substitution.
    adwaita-fonts

    # Monospace / developer
    nerd-fonts.geist-mono
    nerd-fonts.jetbrains-mono

    # English sans-serif
    inter
    geist-font

    # Arabic & multilingual sans-serif
    vazirmatn
    ibm-plex # Includes IBM Plex Sans Arabic & IBM Plex Serif

    # Arabic & English serif
    amiri
    noto-fonts # Noto Sans/Naskh Arabic as Unicode fallback

    # Emoji
    noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        "Adwaita Sans"
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
