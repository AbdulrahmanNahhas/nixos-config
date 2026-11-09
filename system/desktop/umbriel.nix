{
  # Register a second greeter session and its screen-sharing portal.
  programs.umbriel.enable = true;
  xdg.portal.config.umbriel = {
    default = [
      "umbriel"
      "gtk"
    ];
    "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
  };
}
