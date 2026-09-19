{ pkgs, config, ... }:
{
  # WhatsApp Web installed as an app from Brave's own menu; the app id is
  # derived from its URL, so it is stable across profiles.
  xdg.desktopEntries.brave-whatsapp = {
    name = "WhatsApp";
    genericName = "Messaging";
    comment = "WhatsApp Web installed in Brave";
    exec = "brave-origin --profile-directory=Default --app-id=hnpfjngllnobngcgfapefoaidbinmjnm";
    icon = "whatsapp";
    terminal = false;
    categories = [
      "Network"
      "InstantMessaging"
    ];
    settings.StartupWMClass = "whatsapp-web";
  };

  xdg.desktopEntries.rust-book = {
    name = "Rust Book";
    genericName = "Documentation";
    comment = "Interactive Rust Book App";
    exec = ''brave-origin --user-data-dir="${config.home.homeDirectory}/.config/rust-book-brave" --class="rust-book-app" --force-dark-mode --app="https://rust-book.cs.brown.edu/"'';

    icon = pkgs.fetchurl {
      url = "https://rustacean.net/assets/rustacean-flat-happy.svg";
      hash = "sha256-TaGUexybrltg07vuaqkzvFlr+LhDifB8lOyiB2yqz48=";
    };

    terminal = false;
    categories = [
      "Development"
      "Documentation"
    ];
    settings.StartupWMClass = "rust-book-app";
  };
}
