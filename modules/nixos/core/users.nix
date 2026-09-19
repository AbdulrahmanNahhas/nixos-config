{
  config,
  pkgs,
  username,
  ...
}:
{
  # Keep authentication reproducible across the tmpfs root. Password changes
  # must be made by updating the encrypted hash rather than with `passwd`.
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
          "video"
          "input"
          "audio"
          "render"
          "gamemode"
          "openrazer"
          "dialout"
        ];
        shell = pkgs.fish;
      };
    };
  };
}
