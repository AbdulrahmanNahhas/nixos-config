{
  config,
  username,
  ...
}:
let
  encryptedSecretRoot = ../../../encrypted-secrets;
  noctaliaConfig = builtins.readFile ../../home/wm/noctalia/config.toml;
in
{
  sops = {
    age = {
      # This identity lives on the encrypted, persistent /saved filesystem.
      # Provision and back it up before activating a configuration that declares
      # encrypted secrets; generating a replacement cannot decrypt old secrets.
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

      nix-config = {
        sopsFile = encryptedSecretRoot + /nix.conf.enc;
        format = "binary";
        owner = username;
        group = "users";
        mode = "0400";
      };

      noctalia-anilist-token = {
        sopsFile = encryptedSecretRoot + /noctalia-anilist-token.enc;
        format = "binary";
      };

      noctalia-wallhaven-api-key = {
        sopsFile = encryptedSecretRoot + /noctalia-wallhaven-api-key.enc;
        format = "binary";
      };
    };

    templates."noctalia-config.toml" = {
      content =
        builtins.replaceStrings
          [
            "@ANILIST_TOKEN@"
            "@WALLHAVEN_API_KEY@"
          ]
          [
            config.sops.placeholder."noctalia-anilist-token"
            config.sops.placeholder."noctalia-wallhaven-api-key"
          ]
          noctaliaConfig;
      owner = username;
      group = "users";
      mode = "0600";
    };
  };
}
