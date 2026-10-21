{
  networking = {
    nameservers = [
      "127.0.0.1"
      "::1"
    ];
    networkmanager = {
      enable = true;
      dns = "none";
      wifi.macAddress = "random";
      wifi.scanRandMacAddress = true;
      # Do not advertise the machine name to each DHCP server by default.
      # Explicit per-connection choices can override these global defaults.
      settings.connection = {
        "ipv4.dhcp-send-hostname" = false;
        "ipv6.dhcp-send-hostname" = false;
      };
    };
    tempAddresses = "enabled";
  };

  services = {
    resolved.enable = false;
    samba.enable = false;
    avahi.enable = false;
  };
}
