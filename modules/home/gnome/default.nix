{
  # Retain GTK application preferences and Files bookmarks, but do not install
  # GNOME Shell extensions when Niri is the only desktop session.
  imports = [
    ./bookmarks.nix
    ./dconf.nix
  ];
}
