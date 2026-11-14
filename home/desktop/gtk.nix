{ config, pkgs, ... }:
{
  gtk = {
    enable = true;
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  xdg.configFile."cosmic/com.system76.CosmicTk/v1/icon_theme".text = ''
    "${config.gtk.iconTheme.name}"
  '';

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    dotIcons.enable = false;
    x11.enable = false; # Need to Check cursor appearance in XWayland apps...
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 26;
  };
}
