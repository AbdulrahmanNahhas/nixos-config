{
  networking.firewall = {
    enable = true;

    # Everything else stays closed, including SimpleX and GSConnect.
    interfaces.wlan0.allowedTCPPorts = [
      8083 # Kavita
      23101 # Nahhas Cinema API (Node.js)
      5432 # PostgreSQL
    ];
  };
}
