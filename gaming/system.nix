{ pkgs, username, ... }:
{
  hardware.graphics.enable32Bit = true;

  programs = {
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
    gamemode.enable = true;
    xwayland.enable = true;
  };

  preservation.preserveAt."/saved".users.${username}.directories = [
    ".local/share/Steam"
    ".steam"
  ];

  systemd.tmpfiles.rules = [
    "d /saved/games 0755 ${username} users -"
  ];

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];
}
