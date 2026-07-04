{
  username,
  inputs,
  ...
}:

{
  programs.firefox = {
    enable = true;

    # ── Add-ons ──────────
    policies.ExtensionSettings = {
      # uBlock Origin
      "uBlock0@raymondhill.net" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        installation_mode = "force_installed";
      };
      # extension ID from about:support.
    };

    profiles.aqua = {
      isDefault = true;
      name = "${username}";
      path = "aqua";

      # ── Search engines ───────────────────────────────────
      search = {
        force = true;
        default = "ddg";
        engines = {
          "Nix Packages" = {
            urls = [ { template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}"; } ];
            icon = "https://nixos.org/favicon.png";
            definedAliases = [ "@np" ];
          };
          "bing".metaData.hidden = true;
          "ebay".metaData.hidden = true;
        };
      };

      # ── about:config prefs ───────────────────────────────
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
        "ui.systemUsesDarkTheme" = 1;
        "gnomeTheme.hideSingleTab" = false;
        "gnomeTheme.tabsAsHeaderbar" = true;
        "gnomeTheme.normalWidthTabs" = false;
        "gnomeTheme.activeTabContrast" = false;
        "gnomeTheme.hideWebrtcIndicator" = true;
        "gnomeTheme.systemIcons" = false;
        "gnomeTheme.bookmarksToolbarUnderTabs" = false;
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
        "extensions.autoDisableScopes" = 0;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };

      # ── GNOME theme CSS ────
      userChrome = ''
        @import "firefox-gnome-theme/userChrome.css";
      '';

      userContent = ''
        @import "firefox-gnome-theme/userContent.css";
      '';
    };
  };

  # ── Symlink the Theme into the Profile ──────────────────
  # This physically places the theme assets inside your profile's chrome directory
  # where Firefox is legally allowed to read them.
  home.file.".mozilla/firefox/aqua/chrome/firefox-gnome-theme".source = inputs.firefox-gnome-theme;
}
