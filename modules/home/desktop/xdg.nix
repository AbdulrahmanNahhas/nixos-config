{ config, ... }:
{
  xdg = {
    terminal-exec = {
      enable = true;
      settings = {
        default = [ "com.mitchellh.ghostty.desktop" ];
        GNOME = [ "com.mitchellh.ghostty.desktop" ];
      };
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "librewolf.desktop" ];
        "x-scheme-handler/http" = [ "librewolf.desktop" ];
        "x-scheme-handler/https" = [ "librewolf.desktop" ];
        "x-scheme-handler/about" = [ "librewolf.desktop" ];
        "x-scheme-handler/unknown" = [ "librewolf.desktop" ];
        "x-scheme-handler/chrome" = [ "librewolf.desktop" ];
        "application/x-extension-htm" = [ "librewolf.desktop" ];
        "application/x-extension-html" = [ "librewolf.desktop" ];
        "application/x-extension-shtml" = [ "librewolf.desktop" ];
        "application/xhtml+xml" = [ "librewolf.desktop" ];
        "application/x-extension-xhtml" = [ "librewolf.desktop" ];
        "application/x-extension-xht" = [ "librewolf.desktop" ];
        "application/pdf" = [ "org.gnome.Papers.desktop" ];
        "application/x-bzpdf" = [ "org.gnome.Papers.desktop" ];
        "application/x-ext-pdf" = [ "org.gnome.Papers.desktop" ];
        "application/x-gzpdf" = [ "org.gnome.Papers.desktop" ];
        "application/x-xzpdf" = [ "org.gnome.Papers.desktop" ];
      };
    };

    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      publicShare = "${config.home.homeDirectory}/Public";
      templates = "${config.home.homeDirectory}/Templates";
      videos = "${config.home.homeDirectory}/Videos";
      projects = "${config.home.homeDirectory}/Projects";
    };
  };
}
