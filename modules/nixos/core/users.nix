{
  config,
  pkgs,
  username,
  ...
}:
{
  # Update the encrypted password hash; passwd changes are not durable.
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
          # Use logind/PipeWire access; permanent device groups bypass session controls.
          "render"
          "gamemode"
          "openrazer"
        ];
        shell = pkgs.fish;
      };
    };
  };
}
