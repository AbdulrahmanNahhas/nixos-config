{
  config,
  username,
  ...
}:
{
  imports = [
    ../../profiles/home
    ../../profiles/home/desktop.nix
    ../../profiles/home/development.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
    sessionVariables = {
      PATH = "/etc/profiles/per-user/${config.home.username}/bin:$PATH";
      EDITOR = "micro";
      VISUAL = "micro";
    };
  };

  programs.home-manager.enable = true;

  # Decrypted at activation by sops-nix; the link contains no secret material.
  home.file.".config/nix/nix.conf".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/nix-config";
}
