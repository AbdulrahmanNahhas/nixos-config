{
  imports = [ ./preservation.nix ];

  # /nix, /saved, and /swap are subvolumes of one Btrfs filesystem. Scrubbing
  # one mount checks all data and metadata without scheduling duplicate work.
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/saved" ];
    interval = "monthly";
  };

  # Compressed swap in RAM, tried before the 16 GiB swapfile (priority 5 vs
  # -1). Keeps the disk swap as overflow for large model loads.
  zramSwap.enable = true;

  # Monitor the NVMe drive's health and notify logged-in users on warnings.
  services.smartd.enable = true;
}
