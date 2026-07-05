{ ... }:
{
  programs.firefox.profiles.aqua.settings = {
    # ── Theme: enable userChrome/userContent CSS ───────────────────────────
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "svg.context-properties.content.enabled" = true; # recolor theme icons
    "ui.systemUsesDarkTheme" = 1;

    # ── firefox-gnome-theme option toggles (about:config booleans) ────────
    "gnomeTheme.hideSingleTab" = false;
    "gnomeTheme.tabsAsHeaderbar" = true;
    "gnomeTheme.normalWidthTabs" = false;
    "gnomeTheme.activeTabContrast" = false;
    "gnomeTheme.hideWebrtcIndicator" = true;
    "gnomeTheme.systemIcons" = false;
    "gnomeTheme.bookmarksToolbarUnderTabs" = false;

    # ── Recommended prefs from upstream configuration/user.js ──────────────
    "browser.uidensity" = 0; # normal UI density
    "browser.theme.dark-private-windows" = false;
    "widget.gtk.rounded-bottom-corners.enabled" = true;

    # ── New tab / homepage ─────────────────────────────────────────────────
    "browser.startup.homepage" = "about:home";
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
    "browser.newtabpage.activity-stream.feeds.topsites" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

    # ── URL bar ───────────────────────────────────────────────────────────
    "browser.tabs.searchclipboardfor.middleclick" = true;
    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;
    "browser.urlbar.trimURLs" = false;

    # ── Downloads / security / extensions ─────────────────────────────────
    "browser.download.useDownloadDir" = true;
    "dom.security.https_only_mode" = true;
    "extensions.autoDisableScopes" = 0;

    # ── Use the XDG desktop portal file picker (Wayland) ──────────────────
    "widget.use-xdg-desktop-portal.file-picker" = 1;
  };
}
