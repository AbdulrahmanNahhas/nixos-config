{ pkgs, ... }:
{
  # Collects every font below into the system font dir;
  # desktop/flatpak-theming.nix mirrors the same set onto /usr/share/fonts so
  # flatpak sandboxes see more than their runtime's own handful.
  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    # UI sans-serif. desktop/dconf.nix names Adwaita Sans/Mono explicitly;
    # without the package fontconfig silently resolves it to whatever sorts
    # first (observed live: Noto Sans CJK KR).
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
