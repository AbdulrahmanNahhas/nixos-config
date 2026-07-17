{ pkgs, username, ... }:
{
  # TODO: Replace installation-only plaintext passwords with a secure credential flow.
  users.users.root.initialPassword = "changeme";
  users.users.${username} = {
    isNormalUser = true;
    initialPassword = "changeme";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
      "audio"
      "render"
      "gamemode"
      "openrazer"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [ tree ];
  };
}
