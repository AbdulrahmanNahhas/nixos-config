{
  networking.firewall = {
    enable = true;
    interfaces.wlan0.allowedTCPPorts = [
      8083 # Kavita
      23101 # Nahhas Cinema API (Node.js)
      5432 # PostgreSQL
    ];

    # SimpleX is currently closed:
    # allowedTCPPorts = [ 36679 ];
    # allowedUDPPorts = [ 36679 ];

    # GSConnect is currently closed:
    # allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    # allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };
}
