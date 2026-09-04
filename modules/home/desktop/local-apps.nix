{ ... }:
{
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
