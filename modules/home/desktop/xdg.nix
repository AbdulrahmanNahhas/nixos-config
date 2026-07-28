{ config, ... }:
{
  xdg = {
    terminal-exec = {
      enable = true;
      settings = {
        default = [ "com.mitchellh.ghostty.desktop" ];
      };
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        # Web browser (LibreWolf remains the system default)
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

        # Video Player (Cine)
        "video/mp4" = [ "io.github.diegopvlk.Cine.desktop" ];
        "video/x-matroska" = [ "io.github.diegopvlk.Cine.desktop" ];
        "video/webm" = [ "io.github.diegopvlk.Cine.desktop" ];
        "video/quicktime" = [ "io.github.diegopvlk.Cine.desktop" ];
        "video/x-msvideo" = [ "io.github.diegopvlk.Cine.desktop" ];
        "video/x-flv" = [ "io.github.diegopvlk.Cine.desktop" ];
        "video/mpeg" = [ "io.github.diegopvlk.Cine.desktop" ];
        "video/ogg" = [ "io.github.diegopvlk.Cine.desktop" ];
        "video/3gp" = [ "io.github.diegopvlk.Cine.desktop" ];

        # Audio Player (Amberol)
        "audio/mpeg" = [ "io.bassi.Amberol.desktop" ];
        "audio/flac" = [ "io.bassi.Amberol.desktop" ];
        "audio/wav" = [ "io.bassi.Amberol.desktop" ];
        "audio/x-wav" = [ "io.bassi.Amberol.desktop" ];
        "audio/ogg" = [ "io.bassi.Amberol.desktop" ];
        "audio/aac" = [ "io.bassi.Amberol.desktop" ];
        "audio/m4a" = [ "io.bassi.Amberol.desktop" ];
        "audio/mp4" = [ "io.bassi.Amberol.desktop" ];

        # Image Viewer (Loupe)
        "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
        "image/png" = [ "org.gnome.Loupe.desktop" ];
        "image/gif" = [ "org.gnome.Loupe.desktop" ];
        "image/webp" = [ "org.gnome.Loupe.desktop" ];
        "image/avif" = [ "org.gnome.Loupe.desktop" ];
        "image/bmp" = [ "org.gnome.Loupe.desktop" ];
        "image/tiff" = [ "org.gnome.Loupe.desktop" ];
        "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
        "image/heif" = [ "org.gnome.Loupe.desktop" ];

        # Document / PDF Viewer (Papers)
        "application/pdf" = [ "org.gnome.Papers.desktop" ];
        "application/x-bzpdf" = [ "org.gnome.Papers.desktop" ];
        "application/x-ext-pdf" = [ "org.gnome.Papers.desktop" ];
        "application/x-gzpdf" = [ "org.gnome.Papers.desktop" ];
        "application/x-xzpdf" = [ "org.gnome.Papers.desktop" ];

        # Office Documents (OnlyOffice)
        "application/msword" = [ "org.onlyoffice.desktopeditors.desktop" ];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
          "org.onlyoffice.desktopeditors.desktop"
        ];
        "application/vnd.ms-excel" = [ "org.onlyoffice.desktopeditors.desktop" ];
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [
          "org.onlyoffice.desktopeditors.desktop"
        ];
        "application/vnd.ms-powerpoint" = [ "org.onlyoffice.desktopeditors.desktop" ];
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [
          "org.onlyoffice.desktopeditors.desktop"
        ];
        "application/vnd.oasis.opendocument.text" = [ "org.onlyoffice.desktopeditors.desktop" ];
        "application/vnd.oasis.opendocument.spreadsheet" = [ "org.onlyoffice.desktopeditors.desktop" ];

        # File Manager & Text
        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
        "text/plain" = [ "org.gnome.TextEditor.desktop" ];
        "text/markdown" = [ "org.gnome.TextEditor.desktop" ];
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
