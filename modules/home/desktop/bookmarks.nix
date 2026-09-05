{ config, ... }:
{
  # Sidebar shortcuts for the GTK file chooser (Niri's portal file picker).
  # COSMIC Files keeps its own favourites under ~/.config/cosmic.
  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file://${config.home.homeDirectory}/Documents Documents
    file://${config.home.homeDirectory}/Projects Projects
    file://${config.home.homeDirectory}/Music Music
    file://${config.home.homeDirectory}/Pictures Pictures
    file://${config.home.homeDirectory}/Videos Videos
    file://${config.home.homeDirectory}/Books Books
    file://${config.home.homeDirectory}/Downloads Downloads
    file:///saved/nixos-config nixos-config
  '';
}
