{
  imports = [ ./preservation.nix ];

  # One scrub covers the shared /nix, /saved and /swap filesystem.
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/saved" ];
    interval = "monthly";
  };

  # Prefer zRAM (priority 5); use disk swap (-1) as overflow.
  zramSwap.enable = true;

  # Monitor the NVMe drive's health and notify logged-in users on warnings.
  services.smartd = {
    enable = true;
    # Match SMART’s save prefix to its persistent StateDirectory.
    extraOptions = [ "--savestates=/var/lib/smartmontools/" ];
  };
  systemd.services.smartd.serviceConfig = {
    StateDirectory = "smartmontools";
    StateDirectoryMode = "0700";
  };
}
