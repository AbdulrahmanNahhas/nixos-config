{
  networking.firewall = {
    enable = true;

    # Personal services bind to loopback; no incoming LAN ports are needed.
  };
}
