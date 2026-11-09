{
  networking.firewall = {
    enable = true;
    # Add inbound exceptions only for services that actually need them.
    # Example: expose a service on TCP 3000 through the Wi-Fi interface only.
    # interfaces.wlan0.allowedTCPPorts = [ 3000 ];
    # The service must also listen on a LAN address, not just 127.0.0.1.
  };
}
