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
      # Hide DHCP hostnames by default; connections can override this.
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
