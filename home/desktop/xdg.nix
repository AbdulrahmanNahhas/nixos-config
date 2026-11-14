{ config, lib, ... }:
let
  # Packages and Flatpaks are declared by their owning app configurations.
  handlers = {
    "firefox.desktop" = [
      "text/html"
      "application/xhtml+xml"
      "application/x-extension-htm"
      "application/x-extension-html"
      "application/x-extension-shtml"
      "application/x-extension-xht"
      "application/x-extension-xhtml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
    ];

    "com.system76.CosmicFiles.desktop" = [ "inode/directory" ];

    "com.system76.CosmicEdit.desktop" = [
      "text/plain"
      "text/markdown"
      "application/json"
      "application/x-zerosize"
    ];

    "org.gnome.Loupe.desktop" = [
      "image/jpeg"
      "image/png"
      "image/x-png"
      "image/gif"
      "image/webp"
      "image/avif"
      "image/jxl"
      "image/bmp"
      "image/tiff"
      "image/svg+xml"
      "image/heif"
    ];

    "io.github.diegopvlk.Cine.desktop" = [
      "video/mp4"
      "video/x-matroska"
      "video/webm"
      "video/quicktime"
      "video/x-msvideo"
      "video/x-flv"
      "video/mpeg"
      "video/ogg"
      "video/3gp"
      "video/3gpp"
      "video/3gpp2"
      "video/mp2t"
      "audio/mpeg"
      "audio/flac"
      "audio/x-flac"
      "audio/wav"
      "audio/x-wav"
      "audio/ogg"
      "audio/x-vorbis+ogg"
      "audio/opus"
      "audio/x-opus+ogg"
      "audio/aac"
      "audio/m4a"
      "audio/mp4"
      "audio/webm"
    ];

    "com.github.johnfactotum.Foliate.desktop" = [
      "application/epub+zip"
      "application/vnd.comicbook+zip"
      "application/x-cbz"
    ];

    "org.gnome.Papers.desktop" = [
      "application/pdf"
      "application/x-bzpdf"
      "application/x-ext-pdf"
      "application/x-gzpdf"
      "application/x-xzpdf"
      "application/postscript"
      "application/x-djvu"
      "image/vnd.djvu"
      "application/x-cbr"
    ];
  };
in
{
  xdg.enable = true;

  xdg = {
    terminal-exec = {
      enable = true;
      settings.default = [ "com.mitchellh.ghostty.desktop" ];
    };

    mimeApps = {
      enable = true;
      defaultApplications = lib.concatMapAttrs (
        desktop: types: lib.genAttrs types (_: [ desktop ])
      ) handlers;
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
