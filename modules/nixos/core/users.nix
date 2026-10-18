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
          # logind grants seat devices to the active desktop session; PipeWire
          # handles audio. Permanent input/audio/video access bypasses that
          # lifecycle, and raw keyboard or serial access is not needed here.
          "render"
          "gamemode"
          "openrazer"
        ];
        shell = pkgs.fish;
      };
    };
  };
}
