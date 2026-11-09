{
  config,
  lib,
  pkgs,
  ...
}:
let
  toml = pkgs.formats.toml { };
  cursor = config.home.pointerCursor;
  workspaceKeys = lib.listToAttrs (
    lib.concatMap (n: [
      {
        name = "Mod+${toString n}";
        value = "workspace-switch ${toString n}";
      }
      {
        name = "Mod+Shift+${toString n}";
        value = "window-move-to-workspace ${toString n}";
      }
    ]) (lib.range 1 9)
  );
in
{
  # Noctalia already starts with graphical-session.target.
  xdg.configFile."umbriel/config.toml".source = toml.generate "umbriel-config.toml" {
    input.keyboard = {
      layout = "us,ara";
      options = "grp:alt_shift_toggle";
    };
    input.cursor = {
      theme = cursor.name;
      size = cursor.size;
    };
    keybinds = workspaceKeys // {
      "Mod" = "spawn noctalia msg panel-toggle launcher";
      "Mod+Return" = "spawn ghostty";
      "Mod+T" = "spawn ghostty";
      "Mod+B" = "spawn firefox";
      "Mod+E" = "spawn ghostty -e yazi";
      "Mod+Q" = "window-close";
      "Mod+F" = "window-toggle-fullscreen";
      "Mod+O" = "overview-toggle";
      "Mod+Shift+Space" = "window-toggle-floating";
      "Mod+Escape" = "session-quit";
      "Mod+Alt+L" = "spawn noctalia msg session lock";
      "Mod+Left" = "window-focus-left";
      "Mod+Right" = "window-focus-right";
      "Mod+Up" = "window-focus-up";
      "Mod+Down" = "window-focus-down";
      "Mod+Shift+Left" = "column-move-left";
      "Mod+Shift+Right" = "column-move-right";
      "Mod+Shift+Up" = "window-move-up";
      "Mod+Shift+Down" = "window-move-down";
      "XF86AudioRaiseVolume" = "spawn noctalia msg volume-up";
      "XF86AudioLowerVolume" = "spawn noctalia msg volume-down";
      "XF86AudioMute" = "spawn noctalia msg volume-mute";
      "XF86MonBrightnessUp" = "spawn noctalia msg brightness-up";
      "XF86MonBrightnessDown" = "spawn noctalia msg brightness-down";
      "Print" = "spawn noctalia msg screenshot-region";
    };
  };
}
