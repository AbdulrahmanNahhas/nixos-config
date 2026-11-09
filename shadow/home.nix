{
  config,
  username,
  ...
}:
{
  imports = [
    ../modules/home/shell
    ../modules/home/desktop
    ../modules/home/programs
    ../modules/home/packages
    ../modules/home/wm
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
    sessionVariables = {
      EDITOR = "hx";
      VISUAL = "zeditor --wait";
    };
  };

  programs.home-manager.enable = true;

  # Together with the 6 GiB Nix budget, leave headroom on this 16 GiB host.
  systemd.user.slices.build.Slice = {
    MemoryHigh = "3G";
    MemoryMax = "4G";
    MemorySwapMax = "2G";
  };

  # Decrypted at activation by sops-nix; the link contains no secret material.
  home.file.".config/nix/nix.conf".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/nix-config";
}
