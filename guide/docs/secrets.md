**age** supplies identities. **SOPS** encrypts and edits versionable secret files. **sops-nix** decrypts declared secrets during activation, assigns ownership/modes, and exposes runtime paths. An encrypted archive without a consumer is not an active service configuration.

## Your deployed secrets

The user password hash is decrypted early using `neededForUsers`. Nix configuration is decrypted for Aqua and linked into the home configuration. The Wallhaven token is inserted into a runtime Noctalia template. GitHub and WireGuard ciphertext were archived separately; The networking stage exposes the archived VPN as a protected runtime file for native NetworkManager import.

## Your new everyday helper

```
secret list
secret status example
secret add example /private/path/example
secret add-token example
secret edit example
```

add refuses an existing target and a plaintext source inside this repository. add-token uses a hidden local prompt. New ciphertext is published atomically without overwriting another writer’s file. list and status do not reveal values; edit deliberately opens plaintext in your local editor. Adding ciphertext still requires a consumer.

## Add a file-shaped secret

```
cd /saved/nixos-config
sops encrypt --filename-override encrypted-secrets/example.enc   --input-type binary --output-type binary   --output encrypted-secrets/example.enc /private/path/example
```

Keep the plaintext source outside the repository. Then declare the consumer:

```
sops.secrets.example = {
  sopsFile = ../../../encrypted-secrets/example.enc;
  format = "binary";
  owner = "service-user";
  mode = "0400";
};
# Use config.sops.secrets.example.path in a file-valued service option.
```

The owner and path depend on the actual service. Check that the option reads a file at runtime. Do not use `builtins.readFile` on plaintext or interpolate an actual credential into a Nix setting: evaluated strings may enter the world-readable store.

## Why templates are safe here

The tracked Noctalia TOML contains a token marker. Evaluation replaces it with an opaque sops-nix placeholder, then activation inserts the plaintext into a protected runtime file. Edits to that generated file are temporary; durable edits belong to the tracked template. A token can still be copied by its consuming app, so runtime host security remains important.

## Rotation and recovery

If a provider token leaked, revoke/rotate it at the provider. Re-encryption cannot revoke it. If one age identity is lost, the other can rewrap secrets for a replacement. If both are lost and no independent backup exists, public recipients cannot reconstruct the keys. A KeePass database is already encrypted and mutable; back it up directly rather than wrapping every change in SOPS.

### Changing your login password

Users are declarative. A passwd change is not authoritative across activations. Generate a new password hash through a hidden local prompt, encrypt it into the password-hash ciphertext, build and test while keeping an authenticated recovery terminal, then verify fresh login and sudo before switching. Also consider whether the login keyring password needs a coordinated update.
