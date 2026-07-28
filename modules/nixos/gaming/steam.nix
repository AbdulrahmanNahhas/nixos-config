{ pkgs, username, ... }:
{
  hardware.graphics.enable32Bit = true;

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
      protontricks.enable = true;
    };
    gamemode.enable = true;
    xwayland.enable = true;
  };

  systemd.tmpfiles.rules = [
    "d /saved/games 0755 ${username} users -"
  ];

  environment.systemPackages = with pkgs; [ xwayland-satellite ];
}
