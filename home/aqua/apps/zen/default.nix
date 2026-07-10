{ inputs, username, ... }:
{
  imports = [
    inputs.zen-browser.homeModules.beta

    ./search.nix
    ./settings.nix
  ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    # Changing this key to 'default' ensures Zen claims it natively
    profiles.default = {
      isDefault = true;
      name = "${username}";
      path = "default";
    };
  };
}
