{ config, ... }:
{
  # Preferences shared by the remaining GTK applications and the GTK portal.
  # COSMIC reads none of this; its own settings live under ~/.config/cosmic.
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

    # Values the wallpaper helper and GTK tools read.
    "org/gnome/desktop/background" = {
      picture-uri = "file://${config.home.homeDirectory}/Pictures/Wallpapers/my-neighbor-totoro-sunflowers.png";
      picture-uri-dark = "file://${config.home.homeDirectory}/Pictures/Wallpapers/my-neighbor-totoro-sunflowers.png";
    };
  };
}
