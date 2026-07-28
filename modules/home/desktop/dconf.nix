{ config, ... }:
{
  # Shared GTK/GNOME application preferences. GNOME Shell-specific settings
  # belong nowhere in the Niri-only desktop configuration.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      icon-theme = "MoreWaita";
      font-name = "Adwaita Sans 12";
      document-font-name = "Adwaita Sans 12";
      monospace-font-name = "GeistMono Nerd Font Mono 12";
      font-hinting = "slight";
      enable-animations = true;
      show-battery-percentage = true;
    };

    # Retain the values used by the existing wallpaper helper and GTK tools.
    "org/gnome/desktop/background" = {
      picture-uri = "file://${config.home.homeDirectory}/Pictures/Wallpapers/my-neighbor-totoro-sunflowers.png";
      picture-uri-dark = "file://${config.home.homeDirectory}/Pictures/Wallpapers/my-neighbor-totoro-sunflowers.png";
    };
  };
}
