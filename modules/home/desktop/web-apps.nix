{ pkgs, config, ... }: {
  xdg.desktopEntries.brave-whatsapp = {
    name = "WhatsApp";
    genericName = "Messaging";
    comment = "WhatsApp Web installed in Brave";
    exec = "flatpak run com.brave.Browser --profile-directory=Default --app-id=hnpfjngllnobngcgfapefoaidbinmjnm";
    icon = "whatsapp";
    terminal = false;
    categories = [
      "Network"
      "InstantMessaging"
    ];
    settings = {
      StartupWMClass = "whatsapp-web";
      "X-Flatpak" = "com.brave.Browser";
    };
  };

  xdg.desktopEntries.rust-book = {
    name = "Rust Book";
    genericName = "Documentation";
    comment = "Interactive Rust Book App";
    exec = ''flatpak run --device=dri com.brave.Browser --ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations --user-data-dir="${config.home.homeDirectory}/.config/rust-book-brave" --class="rust-book-app" --name="rust-book-app" --force-dark-mode --app="https://rust-book.cs.brown.edu/"'';

    icon = pkgs.fetchurl {
      url = "https://rustacean.net/assets/rustacean-flat-happy.svg";
      hash = "sha256-TaGUexybrltg07vuaqkzvFlr+LhDifB8lOyiB2yqz48=";
    };

    terminal = false;
    categories = [ "Development" "Documentation" ];
    settings = {
      StartupWMClass = "rust-book-app";
      "X-Flatpak" = "com.brave.Browser";
    };
  };
}
