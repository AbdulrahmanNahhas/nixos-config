_: {
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "GeistMono Nerd Font";
      font-size = 16;
      font-feature = "calt liga zero";
      font-variation = "wght=400";

      window-padding-x = 8;
      window-padding-y = 4;
      window-width = 800;
      window-height = 500;
      window-decoration = "auto";
      window-theme = "auto";
      gtk-titlebar = true;
      background-opacity = 0.92;

      theme = "noctalia";

      confirm-close-surface = false;
      copy-on-select = "clipboard";
      clipboard-trim-trailing-spaces = true;
      mouse-hide-while-typing = true;

      keybind = [
        "super+c=copy_to_clipboard"
        "super+v=paste_from_clipboard"
        "super+shift+c=copy_to_clipboard"
        "super+shift+v=paste_from_clipboard"
      ];

      shell-integration = "fish";
    };
  };
}
