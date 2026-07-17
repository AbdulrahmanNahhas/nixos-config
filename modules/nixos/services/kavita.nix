{
  lib,
  pkgs,
  username,
  ...
}:
{
  services.kavita = {
    enable = true;
    package = pkgs.kavita;
    dataDir = "/var/lib/kavita";
    user = "kavita";
    tokenKeyFile = "/var/lib/kavita/token_key";
    settings = {
      IpAddresses = "0.0.0.0,::";
      Port = 8083;
    };
  };

  systemd.services.kavita = {
    serviceConfig.BindPaths = [ "/home/${username}/Books:/books" ];
    wantedBy = lib.mkForce [ ];
  };
}
