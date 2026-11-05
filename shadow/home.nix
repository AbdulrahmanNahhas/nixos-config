{
  config,
  inputs,
  pkgs,
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
      EDITOR = "nano";
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

  # Hide persistence backing paths as well as their home-directory mounts.
  services.hermes-agent.extraPlugins = [
    (pkgs.runCommand "hermes-plugin-bubblewrap" { } ''
      mkdir -p "$out"
      cp -r ${inputs.hermes-official-plugins}/bubblewrap/. "$out/"
      chmod -R u+w "$out"
      substituteInPlace "$out/sandbox.py" \
        --replace-fail \
          'resolved = list(bubblewrap_home.denied_home_paths(home))' \
          'resolved = ["/saved", *bubblewrap_home.denied_home_paths(home)]'
    '')
  ];

  # Decrypted at activation by sops-nix; the link contains no secret material.
  home.file.".config/nix/nix.conf".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/nix-config";
}
