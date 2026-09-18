{
  virtualisation.docker = {
    enable = true;
    # Hermes starts its sandbox container on demand; no need to boot the daemon.
    enableOnBoot = false;
  };
}
