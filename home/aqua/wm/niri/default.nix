{ config, ... }:
{
  # Symlink the main config
  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "/saved/nixos-config/home/aqua/wm/niri/config.kdl";

  # Symlink the keybindings file (Crucial for your 'include' statement)
  xdg.configFile."niri/binds.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "/saved/nixos-config/home/aqua/wm/niri/binds.kdl";
}
