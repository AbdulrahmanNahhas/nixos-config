# Firefox — GNOME theme + add-ons + search.
#
# Home-manager writes profiles.ini + user.js to the XDG path
# (~/.config/mozilla/firefox). Firefox reads them from the legacy path
# (~/.mozilla/firefox). The activation hook below syncs the managed
# files on every rebuild. Profile data (sqlite, logins, cookies) lives
# under the legacy path and is bind-mounted on /saved by preservation.nix.
{
  config,
  lib,
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

  # ── Sync home-manager's XDG files to Firefox's legacy path ─────
  # Firefox reads profiles.ini + user.js from ~/.mozilla/firefox (legacy).
  # Home-manager writes them to ~/.config/mozilla/firefox (XDG).
  # We copy profiles.ini (not symlink — IsRelative=1 must resolve against
  # the legacy dir where profile data lives) and symlink user.js.
  home.activation.syncFirefoxLegacy = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    XDG_DIR="$HOME/.config/mozilla/firefox"
    LEGACY_DIR="$HOME/.mozilla/firefox"

    if [ -d "$XDG_DIR" ]; then
      # profiles.ini: must be a real file under LEGACY_DIR so that
      # IsRelative=1 + Path=aqua resolves to ~/.mozilla/firefox/aqua/.
      # `cp -f` unlinks a pre-existing read-only destination (Firefox/HM may
      # leave it 0444) before writing, avoiding a spurious 'Permission denied'.
      if [ -f "$XDG_DIR/profiles.ini" ]; then
        cp -f "$XDG_DIR/profiles.ini" "$LEGACY_DIR/profiles.ini"
        chmod 0644 "$LEGACY_DIR/profiles.ini"
      fi

      # user.js: symlink each profile's managed prefs into the legacy path
      for profile_dir in "$XDG_DIR"/*/; do
        name=$(basename "$profile_dir")
        case "$name" in
          "Crash Reports"|"Profile Groups") continue ;;
        esac

        mkdir -p "$LEGACY_DIR/$name"

        if [ -L "$XDG_DIR/$name/user.js" ]; then
          target=$(readlink "$XDG_DIR/$name/user.js")
          ln -sf "$target" "$LEGACY_DIR/$name/user.js"
        fi
      done
    fi
  '';
}
