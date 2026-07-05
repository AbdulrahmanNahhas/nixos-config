{ username, ... }:
{
  imports = [
    ./search.nix
    ./policies.nix
    ./settings.nix
    ./theme.nix
  ];

  programs.firefox = {
    enable = true;

    profiles.aqua = {
      isDefault = true;
      name = "${username}";
      path = "aqua";
    };
  };
}
