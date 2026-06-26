# Firefox — GNOME theme (Master) + addons + search
#
# The Firefox profile (cookies, saved logins, sessions, history) is
# preserved across reboots by storing the profile path directly on the
# persistent /saved btrfs subvolume (see `profiles.aqua.path` below).
# modules/preservation.nix creates a symlink ~/.mozilla → /saved/home/aqua/.mozilla
# so profiles.ini and the whole Firefox tree lives on persistent storage.
# No activation hack needed.
{
  # config,
  username,
  inputs,
  ...
}:

{
  programs.firefox = {
    enable = true;

    # ── Declarative Add-ons (via Policies) ───────────────
    policies = {
      ExtensionSettings = {
        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        # TODO: Add more extensions here by grabbing their IDs from about:support
      };
    };

    profiles.aqua = {
      isDefault = true;
      name = "${username}";

      # Store profile directly on the persistent volume (/saved) so history,
      # logins, sessions, and cookies survive the tmpfs root being wiped.
      # This avoids any timing races between preservation (systemd-tmpfiles)
      # and home-manager activation competing over a ~/.mozilla symlink.
      path = "/saved/home/aqua/.mozilla/firefox/aqua";

      # ── Search Engine Settings ────────────────────────
      search = {
        force = true;
        default = "ddg";
        engines = {
          "Nix Packages" = {
            urls = [{ template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}"; }];
            icon = "https://nixos.org/favicon.png";
            definedAliases = [ "@np" ];
          };
          # Hides clutter search providers
          "bing".metaData.hidden = true;
          "ebay".metaData.hidden = true;
        };
      };

      # ── Required about:config prefs for the GNOME theme ──
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;

        "gnomeTheme.hideSingleTab" = false;
        "gnomeTheme.tabsAsHeaderbar" = true;
        "gnomeTheme.normalWidthTabs" = false;
        "gnomeTheme.activeTabContrast" = false;
        "gnomeTheme.hideWebrtcIndicator" = true;
        "gnomeTheme.systemIcons" = false;
        "gnomeTheme.bookmarksToolbarUnderTabs" = false;

        # ── Firefox behavior preferences ──────────────────
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
        "extensions.autoDisableScopes" = 0; # Essential: Autolocks extensions on without confirmation popups
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };

      # ── userChrome.css — Dynamic Master Branch via Flakes ─
      userChrome = ''
        @import "${inputs.firefox-gnome-theme}/userChrome.css";
      '';

      # ── userContent.css — Dynamic Master Branch via Flakes ─
      userContent = ''
        @import "${inputs.firefox-gnome-theme}/userContent.css";
      '';
    };
  };
}
