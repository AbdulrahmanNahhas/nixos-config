{ pkgs, inputs, ... }:

{
  programs.firefox.profiles.main = {
    id = 0;
    isDefault = true;
    path = "default";

    userChrome = ../styles/main.css;

    extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
      pywalfox
      stylus
      darkreader
      refined-github
      return-youtube-dislikes
    ];

    search = {
      force = true;
      default = "ddg";
      privateDefault = "ddg";

      engines = {
        nix-software = {
          name = "Nix Software";
          urls = [
            {
              template = "https://nixsoftware.org/en/packages";
              params = [
                {
                  name = "channel";
                  value = "unstable";
                }
                {
                  name = "search";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          definedAliases = [ "@nix" ];
        };

        nixos-options = {
          name = "NixOS Options";
          urls = [
            {
              template = "https://search.nixos.org/options";
              params = [
                {
                  name = "channel";
                  value = "unstable";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          definedAliases = [ "@no" ];
        };

        alternativeto = {
          name = "AlternativeTo";
          urls = [
            {
              template = "https://alternativeto.net/browse/search/?q={searchTerms}";
            }
          ];
          definedAliases = [ "@alt" ];
        };

        youtube = {
          name = "YouTube";
          urls = [
            {
              template = "https://www.youtube.com/results?search_query={searchTerms}";
            }
          ];
          definedAliases = [ "@yt" ];
        };

        chatgpt = {
          name = "ChatGPT";
          urls = [
            {
              template = "https://chatgpt.com/?q={searchTerms}";
            }
          ];
          definedAliases = [ "@gpt" ];
        };

        gemini = {
          name = "Google Gemini";
          urls = [
            {
              template = "https://gemini.google.com/app?prompt={searchTerms}";
            }
          ];
          definedAliases = [ "@gem" ];
        };

        github = {
          name = "GitHub";
          urls = [
            {
              template = "https://github.com/search?q={searchTerms}";
            }
          ];
          definedAliases = [ "@gh" ];
        };

        reddit = {
          name = "Reddit";
          urls = [
            {
              template = "https://www.reddit.com/search/?q={searchTerms}";
            }
          ];
          definedAliases = [ "@reddit" ];
        };
      };
    };

    settings = {
      "extensions.autoDisableScopes" = 0;

      # Do not remember passwords or autofill credentials.
      "signon.rememberSignons" = false;
      "signon.autofillForms" = false;

      # Clear browsing data on shutdown.
      "privacy.sanitize.sanitizeOnShutdown" = true;
      "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = false;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
      "privacy.clearOnShutdown_v2.cache" = true;
      "privacy.clearOnShutdown_v2.formdata" = true;
      "privacy.clearOnShutdown_v2.siteSettings" = false;
    };
  };
}
