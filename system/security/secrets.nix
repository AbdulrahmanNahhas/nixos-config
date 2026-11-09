{
  config,
  username,
  ...
}:
let
  encryptedSecretRoot = ../../encrypted-secrets;
  noctaliaConfig = builtins.readFile ../../home/desktop/noctalia/config.toml;
in
{
  sops = {
    age = {
      # Provision and back up the existing identity outside this repository.
      keyFile = "/saved/var/lib/sops-nix/key.txt";
      generateKey = false;
    };

    secrets = {
      aqua-password-hash = {
        sopsFile = encryptedSecretRoot + /aqua-password-hash.enc;
        format = "binary";
        # User creation happens before normal activation secrets are installed.
        neededForUsers = true;
      };

      # Runtime import file; NetworkManager owns the active connection.
      vpn-shadow = {
        sopsFile = encryptedSecretRoot + /wireguard-shadow.conf.enc;
        format = "binary";
        path = "/run/secrets/Shadow-BG-20.conf";
        mode = "0400";
      };

      nix-config = {
        sopsFile = encryptedSecretRoot + /nix.conf.enc;
        format = "binary";
        owner = username;
        group = "users";
        mode = "0400";
      };

      noctalia-wallhaven-api-key = {
        sopsFile = encryptedSecretRoot + /noctalia-wallhaven-api-key.enc;
        format = "binary";
      };
    };

    templates."noctalia-config.toml" = {
      content =
        builtins.replaceStrings
          [ "@WALLHAVEN_API_KEY@" ]
          [ config.sops.placeholder."noctalia-wallhaven-api-key" ]
          noctaliaConfig;
      owner = username;
      group = "users";
      mode = "0600";
    };
  };
}
