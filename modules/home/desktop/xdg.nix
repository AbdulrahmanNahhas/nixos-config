{ config, lib, ... }:
let
  # One entry per handler; every type listed becomes that desktop file's
  # default. COSMIC applications are installed by modules/nixos/desktop/apps.nix.
  handlers = {
    "brave-origin.desktop" = [
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
      "x-scheme-handler/chrome"
      "x-scheme-handler/unknown"
    ];

    # Files also owns archives: like Nautilus before it, it extracts them from
    # the context menu rather than browsing them.
    "com.system76.CosmicFiles.desktop" = [
      "inode/directory"
      "application/zip"
      "application/x-7z-compressed"
      "application/x-tar"
      "application/x-compressed-tar"
      "application/x-bzip-compressed-tar"
      "application/x-xz-compressed-tar"
      "application/x-rar"
    ];

    "com.system76.CosmicEdit.desktop" = [
      "text/plain"
      "text/markdown"
    ];

    "com.system76.CosmicViewer.desktop" = [
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

    "com.system76.CosmicPlayer.desktop" = [
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
    ];

    "com.system76.CosmicReader.desktop" = [ "application/pdf" ];

    # Papers keeps the formats cosmic-reader cannot open.
    "org.gnome.Papers.desktop" = [
      "application/x-bzpdf"
      "application/x-ext-pdf"
      "application/x-gzpdf"
      "application/x-xzpdf"
      "application/postscript"
      "application/x-djvu"
      "image/vnd.djvu"
      "application/x-cbz"
      "application/x-cbr"
    ];

    "io.bassi.Amberol.desktop" = [
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

    "org.libreoffice.LibreOffice.desktop" = [
      "application/msword"
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "application/vnd.ms-excel"
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "application/vnd.ms-powerpoint"
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "application/vnd.oasis.opendocument.text"
      "application/vnd.oasis.opendocument.spreadsheet"
      "application/vnd.oasis.opendocument.presentation"
    ];
  };
in
{
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
