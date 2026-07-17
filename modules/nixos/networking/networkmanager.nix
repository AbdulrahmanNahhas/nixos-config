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
    };
    tempAddresses = "enabled";
  };

  services = {
    resolved.enable = false;
    samba.enable = false;
    avahi.enable = false;
  };
}
