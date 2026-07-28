_: {
  # Brave stores this PWA in its Flatpak profile but does not reliably export a
  # launcher that Noctalia can index, so keep the desktop entry declarative.
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
      StartupWMClass = "crx_hnpfjngllnobngcgfapefoaidbinmjnm";
      "X-Flatpak" = "com.brave.Browser";
    };
  };
}
