# Firefox — GNOME theme + add-ons + search.
#
# The profile lives at ~/.mozilla/firefox/aqua (home-manager's Linux
# configPath is ".mozilla/firefox"; the profile dir defaults to the
# profile key). The whole ~/.mozilla tree is bind-mounted on /saved by
# modules/preservation.nix, so history, logins, cookies and sessions
# survive reboots.
{
  username,
  inputs,
  ...
}:

{
  programs.firefox = {
    enable = true;

    # ── Add-ons (forced via enterprise policies) ──────────
    policies.ExtensionSettings = {
      # uBlock Origin
      "uBlock0@raymondhill.net" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        installation_mode = "force_installed";
      };
      # Add more here — grab the extension ID from about:support.
    };

    profiles.aqua = {
      isDefault = true;
      name = "${username}";

      # ── Search engines ───────────────────────────────────
      search = {
        force = true;
        default = "ddg";
        engines = {
          "Nix Packages" = {
            urls = [{ template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}"; }];
            icon = "https://nixos.org/favicon.png";
            definedAliases = [ "@np" ];
          };
          # Hide clutter providers.
          "bing".metaData.hidden = true;
          "ebay".metaData.hidden = true;
        };
      };

      # ── about:config prefs ───────────────────────────────
      settings = {
        # Required for the GNOME theme's userChrome/userContent CSS.
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;

        # Force dark UI so the GNOME theme renders dark (Firefox may
        # otherwise stay light even under a dark GTK theme).
        "ui.systemUsesDarkTheme" = 1;

        "gnomeTheme.hideSingleTab" = false;
        "gnomeTheme.tabsAsHeaderbar" = true;
        "gnomeTheme.normalWidthTabs" = false;
        "gnomeTheme.activeTabContrast" = false;
        "gnomeTheme.hideWebrtcIndicator" = true;
        "gnomeTheme.systemIcons" = false;
        "gnomeTheme.bookmarksToolbarUnderTabs" = false;

        # ── Behaviour ──────────────────────────────────────
        "browser.startup.homepage" = "about:home";
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.tabs.searchclipboardfor.middleclick" = true;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.uidensity" = 0;
        "browser.urlbar.trimURLs" = false;
        "browser.download.useDownloadDir" = true;
        "dom.security.https_only_mode" = true;
        "extensions.autoDisableScopes" = 0; # enable force-installed add-ons without the popup
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };

      # ── GNOME theme CSS (pulled from the flake input) ────
      userChrome = ''
        @import "${inputs.firefox-gnome-theme}/userChrome.css";
      '';

      userContent = ''
        @import "${inputs.firefox-gnome-theme}/userContent.css";
      '';
    };
  };
}
