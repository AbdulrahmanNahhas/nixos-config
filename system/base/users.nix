{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  programs.fish.enable = true;

  # Change the encrypted hash; passwd changes disappear after reboot.
  users = {
    mutableUsers = false;

    users = {
      root.hashedPassword = "!";

      ${username} = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.aqua-password-hash.path;
        extraGroups = [
          "wheel"
          "networkmanager"
        ]
        ++ lib.optional config.programs.gamemode.enable "gamemode";
        shell = pkgs.fish;
      };
    };
  };
}
