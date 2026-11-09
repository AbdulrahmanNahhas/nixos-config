{ pkgs, ... }:
{
  home.packages = with pkgs; [
    vulkan-tools
  ];
  # Enable the HUD per game instead of injecting it session-wide.
  programs.mangohud.enable = true;

  xdg.desktopEntries = {
    steam-990080 = {
      name = "Hogwarts Legacy";
      genericName = "Video Game";
      comment = "Play on Steam";
      exec = "steam steam://rungameid/990080";
      icon = "/saved/games/icons/hogwarts-legacy-icon.png";
      terminal = false;
      categories = [ "Game" ];

      settings.Keywords = "Games;Gaming;Steam;RPG;Fantasy;";
    };

    steam-1462040 = {
      name = "FF7 Remake Intergrade";
      genericName = "Video Game";
      comment = "Play on Steam";
      exec = "steam steam://rungameid/1462040";
      icon = "/saved/games/icons/final-fantasy-vii-remake.webp";
      terminal = false;
      categories = [ "Game" ];

      settings.Keywords = "Games;Gaming;Steam;RPG;Fantasy;";
    };

    steam-15258153043158368256 = {
      name = "Clair Obscur: Expedition 33";
      genericName = "Video Game";
      comment = "Play via Heroic on Steam";
      exec = "steam steam://rungameid/15258153043158368256";
      icon = "/saved/games/icons/clair-obscur-icon.png";
      terminal = false;
      categories = [ "Game" ];

      settings.Keywords = "Games;Gaming;Steam;Heroic;Epic;RPG;Fantasy;";
    };
  };

}
