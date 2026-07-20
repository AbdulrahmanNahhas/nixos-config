{
  pkgs,
  username,
  ...
}:
{
  imports = [ ./search.nix ];

  programs.librewolf = {
    enable = true;

    # KeePassXC is native too, so the browser bridge stays outside Flatpak
    # compatibility workarounds.
    nativeMessagingHosts = [ pkgs.keepassxc ];

    policies = {
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      HttpsOnlyMode = "force_enabled";
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;

      # LibreWolf clears cookies on shutdown. These origin exceptions retain
      # the selected login sessions; add future trusted sites to both schemes.
      Cookies = {
        Allow = [
          "http://github.com"
          "https://github.com"
        ];
        Behavior = "reject-tracker-and-partition-foreign";
        BehaviorPrivateBrowsing = "reject-tracker-and-partition-foreign";
        Locked = false;
      };

      # Firefox history cannot be retained selectively by origin. Normal
      # windows keep history; use a private window for activity not to retain.
      SanitizeOnShutdown = {
        Cache = true;
        Cookies = true;
        FormData = true;
        History = false;
        Sessions = false;
        SiteSettings = false;
        Locked = false;
      };

      ExtensionSettings."keepassxc-browser@keepassxc.org" = {
        installation_mode = "normal_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser@keepassxc.org/latest.xpi";
        default_area = "navbar";
        private_browsing = false;
      };
    };

    # Keep LibreWolf's anti-fingerprinting, WebGL, telemetry, and network
    # defaults. Only opt into local Safe Browsing checks and crash recovery.
    settings = {
      "browser.safebrowsing.downloads.enabled" = true;
      "browser.safebrowsing.malware.enabled" = true;
      "browser.safebrowsing.phishing.enabled" = true;
      "browser.sessionstore.resume_from_crash" = true;
      "signon.rememberSignons" = false;
    };

    profiles.default = {
      id = 0;
      isDefault = true;
      name = username;
      path = "default";
      settings."extensions.autoDisableScopes" = 0;
    };
  };
}
