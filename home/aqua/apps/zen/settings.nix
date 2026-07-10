{ ... }:
{
  programs.zen-browser.profiles.default = {
    # ── 1. Native Extension Enforcement ───────────────────────────────────
    # (Optional: Requires configuring NUR or standard nix packages for addons)
    # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    #   ublock-origin
    #   keepassxc-browser
    # ];

    # ── 2. Migrated Security & Privacy Policies ──────────────────────────
    settings = {
      "app.shield.optoutstudies.enabled" = false; # Disable Firefox Studies
      "extensions.pocket.enabled" = false; # Disable Pocket
      "signon.rememberSignons" = false; # Disable Password Manager

      "privacy.trackingprotection.enabled" = true;
      "privacy.trackingprotection.socialtracking.enabled" = true;
      "privacy.trackingprotection.cryptomining.enabled" = true;
      "privacy.trackingprotection.fingerprinting.enabled" = true;
      "privacy.trackingprotection.emailtracking.enabled" = true;

      # ── CRITICAL FOR NOCTALIA V5 THEME TO WORK ──────────────────────────
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

      # ── Your Core Styles & UI ───────────────────────────────────────────
      "svg.context-properties.content.enabled" = true;
      "ui.systemUsesDarkTheme" = 1;
      "gfx.webrender.all" = true;
      "browser.startup.homepage" = "about:bliss";
      "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      "browser.newtabpage.activity-stream.feeds.topsites" = false;
      "browser.newtabpage.activity-stream.showSponsored" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      "browser.newtabpage.activity-stream.telemetry" = false;

      # ── Network & Deep Privacy Guard ────────────────────────────────────
      "privacy.donottrackheader.enabled" = true;
      "privacy.partition.network_state.ocsp_cache" = true;
      "media.peerconnection.ice.default_address_only" = true;
      "media.peerconnection.ice.no_host" = true;
      "datareporting.policy.dataSubmissionEnabled" = false;
      "datareporting.healthreport.uploadEnabled" = false;
      "toolkit.telemetry.unified" = false;
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.server" = "data:,";
      "toolkit.telemetry.archive.enabled" = false;
      "toolkit.telemetry.newProfilePing.enabled" = false;
      "toolkit.telemetry.shutdownPing.enabled" = false;
      "dom.enable_high_res_performance_timer" = false;
      "dom.gamepad.enabled" = false;
      "media.navigator.enabled" = false;

      # ── URL Bar & Structural Security ───────────────────────────────────
      "browser.tabs.searchclipboardfor.middleclick" = true;
      "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
      "browser.urlbar.suggest.quicksuggest.sponsored" = false;
      "browser.urlbar.trimURLs" = false;
      "browser.urlbar.speculativeConnect.enabled" = false;
      "browser.download.useDownloadDir" = true;
      "dom.security.https_only_mode" = true;
      "dom.security.https_only_mode_ever_enabled" = true;
      "extensions.autoDisableScopes" = 0;
      "network.http.referer.XOriginTrimmingPolicy" = 2;

      # ── Desktop Integration ─────────────────────────────────────────────
      "widget.use-xdg-desktop-portal.file-picker" = 1;
      "org.mozilla.firefox.win_or_mac_native_messaging" = false;
    };
  };
}
