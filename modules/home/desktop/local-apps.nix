{ ... }:
{
  xdg.desktopEntries.delta = {
    name = "Delta";
    genericName = "Text Editor";
    comment = "AI-native code editor (Zed Delta beta)";

    exec = "/saved/apps/delta-linux-x86_64/Delta/bin/delta cli open %U";
    icon = ./icons/delta.png;

    terminal = false;

    categories = [
      "Development"
      "IDE"
      "TextEditor"
    ];

    mimeType = [ "x-scheme-handler/delta" ];

    settings = {
      StartupWMClass = "dev.zed.Delta";
      Keywords = "delta;editor;ide;";
    };
  };

  xdg.desktopEntries.nahhascinema = {
    name = "Nahhas Cinema";
    genericName = "Family Media Center";
    comment = "Family-focused media center for torrents, Jellyfin, local media, and your personal library.";

    exec = "/saved/apps/NahhasCinema.AppImage";
    icon = ./icons/nahhas-cinema.png;

    terminal = false;

    categories = [
      "AudioVideo"
      "Video"
    ];

    settings = {
      StartupWMClass = "nahhascinema";
      Keywords = "Watch;Cinema;Movies;TV;Jellyfin;Torrent;Media;Library;";
    };
  };
}
