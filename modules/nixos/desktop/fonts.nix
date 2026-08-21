{ pkgs, ... }:
{
  # Aggregates every font below into /run/current-system/sw/share/X11/fonts.
  # desktop/flatpak-theming.nix re-projects the same set onto /usr/share/fonts
  # so flatpak sandboxes pick it up too -- without that, apps only see the
  # handful of fonts their own runtime bundles and any text outside that
  # coverage (Arabic in particular) renders as tofu boxes.
  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    # UI Sans-Serif
    # Adwaita Sans/Mono are what desktop/dconf.nix actually names in
    # org.gnome.desktop.interface; without them installed, fontconfig
    # silently resolves "Adwaita Sans" to whatever sorts first (observed
    # live: Noto Sans CJK KR).
    adwaita-fonts

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
