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
        # Web Browser
        "text/html" = [ "brave-origin.desktop" ];
        "x-scheme-handler/http" = [ "brave-origin.desktop" ];
        "x-scheme-handler/https" = [ "brave-origin.desktop" ];
        "x-scheme-handler/about" = [ "brave-origin.desktop" ];
        "x-scheme-handler/unknown" = [ "brave-origin.desktop" ];
        "x-scheme-handler/chrome" = [ "brave-origin.desktop" ];
        "application/x-extension-htm" = [ "brave-origin.desktop" ];
        "application/x-extension-html" = [ "brave-origin.desktop" ];
        "application/x-extension-shtml" = [ "brave-origin.desktop" ];
        "application/xhtml+xml" = [ "brave-origin.desktop" ];
        "application/x-extension-xhtml" = [ "brave-origin.desktop" ];
        "application/x-extension-xht" = [ "brave-origin.desktop" ];

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
        "video/3gpp" = [ "io.github.diegopvlk.Cine.desktop" ];
        "video/3gpp2" = [ "io.github.diegopvlk.Cine.desktop" ];
        "video/mp2t" = [ "io.github.diegopvlk.Cine.desktop" ];

        # Audio Player (Amberol)
        "audio/mpeg" = [ "io.bassi.Amberol.desktop" ];
        "audio/flac" = [ "io.bassi.Amberol.desktop" ];
        "audio/x-flac" = [ "io.bassi.Amberol.desktop" ];
        "audio/wav" = [ "io.bassi.Amberol.desktop" ];
        "audio/x-wav" = [ "io.bassi.Amberol.desktop" ];
        "audio/ogg" = [ "io.bassi.Amberol.desktop" ];
        "audio/x-vorbis+ogg" = [ "io.bassi.Amberol.desktop" ];
        "audio/opus" = [ "io.bassi.Amberol.desktop" ];
        "audio/x-opus+ogg" = [ "io.bassi.Amberol.desktop" ];
        "audio/aac" = [ "io.bassi.Amberol.desktop" ];
        "audio/m4a" = [ "io.bassi.Amberol.desktop" ];
        "audio/mp4" = [ "io.bassi.Amberol.desktop" ];
        "audio/webm" = [ "io.bassi.Amberol.desktop" ];

        # Image Viewer (Loupe)
        "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
        "image/png" = [ "org.gnome.Loupe.desktop" ];
        "image/gif" = [ "org.gnome.Loupe.desktop" ];
        "image/webp" = [ "org.gnome.Loupe.desktop" ];
        "image/avif" = [ "org.gnome.Loupe.desktop" ];
        "image/jxl" = [ "org.gnome.Loupe.desktop" ];
        "image/bmp" = [ "org.gnome.Loupe.desktop" ];
        "image/tiff" = [ "org.gnome.Loupe.desktop" ];
        "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
        "image/heif" = [ "org.gnome.Loupe.desktop" ];
        "image/x-png" = [ "org.gnome.Loupe.desktop" ];

        # Document / PDF / E-Book Viewer (Papers)
        "application/pdf" = [ "org.gnome.Papers.desktop" ];
        "application/x-bzpdf" = [ "org.gnome.Papers.desktop" ];
        "application/x-ext-pdf" = [ "org.gnome.Papers.desktop" ];
        "application/x-gzpdf" = [ "org.gnome.Papers.desktop" ];
        "application/x-xzpdf" = [ "org.gnome.Papers.desktop" ];
        "application/postscript" = [ "org.gnome.Papers.desktop" ];
        "application/x-djvu" = [ "org.gnome.Papers.desktop" ];
        "image/vnd.djvu" = [ "org.gnome.Papers.desktop" ];
        "application/x-cbz" = [ "org.gnome.Papers.desktop" ];
        "application/x-cbr" = [ "org.gnome.Papers.desktop" ];

        # Office Documents (OnlyOffice)
        "application/msword" = [ "org.libreoffice.LibreOffice.desktop" ];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
          "org.libreoffice.LibreOffice.desktop"
        ];
        "application/vnd.ms-excel" = [ "org.libreoffice.LibreOffice.desktop" ];
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [
          "org.libreoffice.LibreOffice.desktop"
        ];
        "application/vnd.ms-powerpoint" = [ "org.libreoffice.LibreOffice.desktop" ];
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [
          "org.libreoffice.LibreOffice.desktop"
        ];
        "application/vnd.oasis.opendocument.text" = [ "org.libreoffice.LibreOffice.desktop" ];
        "application/vnd.oasis.opendocument.spreadsheet" = [ "org.libreoffice.LibreOffice.desktop" ];
        "application/vnd.oasis.opendocument.presentation" = [ "org.libreoffice.LibreOffice.desktop" ];

        # File Manager & Archives (Nautilus)
        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
        "application/zip" = [ "org.gnome.Nautilus.desktop" ];
        "application/x-7z-compressed" = [ "org.gnome.Nautilus.desktop" ];
        "application/x-tar" = [ "org.gnome.Nautilus.desktop" ];
        "application/x-compressed-tar" = [ "org.gnome.Nautilus.desktop" ];
        "application/x-bzip-compressed-tar" = [ "org.gnome.Nautilus.desktop" ];
        "application/x-xz-compressed-tar" = [ "org.gnome.Nautilus.desktop" ];
        "application/x-rar" = [ "org.gnome.Nautilus.desktop" ];

        # Text & Code
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
