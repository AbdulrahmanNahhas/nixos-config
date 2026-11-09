{ pkgs, ... }:

let
  # Shared browser settings
  commonSettings = {
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

    "browser.aboutConfig.showWarning" = false;
    "browser.shell.checkDefaultBrowser" = false;
    "browser.tabs.warnOnClose" = false;
    "browser.send_pings" = false;

    # Privacy and tracking protection
    "privacy.globalprivacycontrol.enabled" = true;
    "dom.security.https_only_mode" = true;
    "browser.contentblocking.category" = "strict";

    "browser.formfill.enable" = false;

    # Disable search suggestions
    "browser.search.suggest.enabled" = false;
    "browser.urlbar.suggest.searches" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;
    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;

    # Remove sponsored content
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;

    # Reduce speculative network requests
    "browser.urlbar.speculativeConnect.enabled" = false;
    "network.prefetch-next" = false;
    "network.dns.disablePrefetch" = true;
    "network.http.speculative-parallel-limit" = 0;
  };

  mediaLabel = "Firefox Kitsune";
  mediaClass = "firefox-kitsune";

in
{
  imports = [
    ./profiles/main.nix
    ./profiles/kitsune.nix
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;

      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;

      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";

      DisablePocket = true;

      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        MoreFromMozilla = false;
        SkipOnboarding = true;
        UrlbarInterventions = false;
      };

      # Force-install uBlock Origin in both profiles.
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          private_browsing = true;
        };
      };
    };
  };

  # Shared settings, merged into both profiles.
  programs.firefox.profiles.main.settings = commonSettings;
  programs.firefox.profiles.kitsune.settings = commonSettings;

  # Dedicated Kitsune launcher.
  xdg.desktopEntries.firefox-kitsune = {
    name = mediaLabel;
    genericName = "Media Web Browser";
    comment = "Firefox with the Kitsune media profile";

    exec = "${pkgs.firefox}/bin/firefox -P kitsune --new-instance --class ${mediaClass} --name ${mediaClass} %U";

    icon = "${./icons/kitsune-firefox.png}";

    terminal = false;
    startupNotify = true;

    categories = [
      "Network"
      "WebBrowser"
    ];

    settings = {
      StartupWMClass = mediaClass;
    };
  };
}
