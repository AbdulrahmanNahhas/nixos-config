{
  xdg.desktopEntries.nahhascinema = {
    name = "Nahhasio";
    genericName = "Family Media Center";
    comment = "Family-focused media center for torrents, Jellyfin, local media, and your personal library.";

    exec = "/saved/apps/Nahhasio.AppImage";
    icon = ./icons/nahhasio.png;

    terminal = false;

    categories = [
      "AudioVideo"
      "Video"
    ];

    settings = {
      StartupWMClass = "nahhasio";
      Keywords = "Watch;Cinema;Movies;TV;Jellyfin;Torrent;Media;Library;";
    };
  };
}
