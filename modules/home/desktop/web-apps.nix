_: {
  # Brave's Flatpak can install PWAs inside its private profile without
  # exporting desktop launchers. Declare the launcher so Noctalia can index it
  # and use the PWA-specific window class for icon matching.
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
