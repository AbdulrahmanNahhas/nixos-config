{ ... }:
{
  programs.yazi = {
    enable = true;
    settings = {
      manager = {
        ratio = [
          0
          2
          5
        ]; # hide parent pane, shrink file list, maximize preview
      };
    };
    keymap = {
      manager.prepend_keymap = [
        {
          on = [ "w" ];
          run = "shell 'setwallpaper \"$1\"' --confirm";
          desc = "Set as wallpaper";
        }
      ];
    };
  };
}
