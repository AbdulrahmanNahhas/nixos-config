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
      IpAddresses = "127.0.0.1,::1";
      Port = 8083;
    };
  };

  systemd.services.kavita = {
    serviceConfig = {
      BindReadOnlyPaths = [ "/home/${username}/Books:/books" ];
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/kavita" ];
      UMask = "0077";
    };
    wantedBy = lib.mkForce [ ];
  };
}
