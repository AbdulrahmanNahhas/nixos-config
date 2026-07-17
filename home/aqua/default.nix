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

  # Out-of-store symlink: a private nix.conf kept outside the repo
  home.file.".config/nix/nix.conf".source =
    config.lib.file.mkOutOfStoreSymlink "/saved/secrets/nix.conf";
}
