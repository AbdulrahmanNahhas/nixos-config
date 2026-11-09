{ pkgs, inputs, ... }:

{
  programs.firefox.profiles.kitsune = {
    id = 1;
    isDefault = false;
    path = "kitsune";

    userChrome = ../styles/kitsune.css;

    search = {
      force = true;
      default = "ddg";
      privateDefault = "ddg";

      engines = {
        anilist = {
          name = "AniList";
          urls = [
            {
              template = "https://anilist.co/search/anime?search={searchTerms}";
            }
          ];
          definedAliases = [ "@ani" ];
        };

        myanimelist = {
          name = "MyAnimeList";
          urls = [
            {
              template = "https://myanimelist.net/anime.php?q={searchTerms}";
            }
          ];
          definedAliases = [ "@mal" ];
        };

        imdb = {
          name = "IMDb";
          urls = [
            {
              template = "https://www.imdb.com/find/?q={searchTerms}";
            }
          ];
          definedAliases = [ "@imdb" ];
        };

        tmdb = {
          name = "TMDB";
          urls = [
            {
              template = "https://www.themoviedb.org/search?query={searchTerms}";
            }
          ];
          definedAliases = [ "@tmdb" ];
        };

        igdb = {
          name = "IGDB";
          urls = [
            {
              template = "https://www.igdb.com/search?type=1&q={searchTerms}";
            }
          ];
          definedAliases = [ "@games" ];
        };

        rankeo = {
          name = "Rankeo";
          urls = [
            {
              template = "https://rankeo.one/search?q={searchTerms}";
            }
          ];
          definedAliases = [ "@rank" ];
        };
      };
    };

    extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
      darkreader
      stylus

      protondb-for-steam
      steam-database

      mal-sync
      sponsorblock
      return-youtube-dislikes
    ];

    settings = {
      "extensions.autoDisableScopes" = 0;

      # Restore previous media session.
      "browser.startup.page" = 3;

      # Retain saved logins.
      "signon.rememberSignons" = true;
      "signon.autofillForms" = true;

      # Preserve browsing data between sessions.
      "privacy.sanitize.sanitizeOnShutdown" = false;
      "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = false;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
      "privacy.clearOnShutdown_v2.cache" = false;
      "privacy.clearOnShutdown_v2.formdata" = false;
      "privacy.clearOnShutdown_v2.siteSettings" = false;
    };
  };
}
