The desktop controller remains NetworkManager. A WireGuard configuration includes a local private key, address, peer public key, endpoint, and allowed IP ranges. Allowed IPs help select which peer handles which destinations; routing rules decide how traffic reaches the interface. These are not equivalent to a kill switch.

## Use the native NetworkManager workflow

```
nmcli connection show
# Only if this profile is not already present:
sudo nmcli connection import type wireguard file /run/secrets/Shadow-BG-20.conf
nmcli connection modify id Shadow-BG-20 connection.autoconnect no
nmcli connection up id Shadow-BG-20
nmcli connection down id Shadow-BG-20
```

The existing connection is already managed by NetworkManager. Do not import it again merely because you rebuilt. The only new declaration decrypts the existing archive into a root-only runtime file. There is no custom VPN command, Python converter, boot-time import service, or second connection controller. Use the desktop network controls for everyday connect/disconnect.

## The safe addition workflow

1.  Obtain the provider configuration through its trusted channel; keep it outside Git.
2.  Encrypt it using SOPS and the existing recipients.
3.  Declare a SOPS runtime file and import it through NetworkManager only if a new profile is needed.
4.  Leave autoconnect off until the profile is verified.
5.  Connect through the desktop network controls or nmcli.
6.  Verify IPv4, IPv6, DNS, endpoint reachability, and intended LAN access.

`modules/nixos/security/secrets.nix` declares the encrypted archive’s runtime path. To add a second VPN, encrypt its provider file, add an equivalent secret declaration with a unique .conf path, and import it through NetworkManager. The protected NetworkManager connection directory is already preserved across reboot. Importing is an explicit operation; rebuilding does not alter the currently connected VPN. Imported profiles need their autoconnect preference reviewed before relying on their behavior.

## Full tunnel, split tunnel, and fail-closed

A full tunnel aims to route general internet traffic through the VPN. A split tunnel covers selected destinations. A fail-closed policy blocks unwanted traffic when the tunnel is absent; it must retain exceptions for VPN endpoint access, necessary DNS bootstrap, and whatever local networking you choose. It cannot be safely inferred just from the existence of a WireGuard interface.

With the present system resolver ownership, do not assume the provider’s DNS field automatically becomes the system resolver. It may be ignored by the existing policy. Before claiming privacy, test DNS routing and browser DNS, and check that IPv6 does not take an unintended path. The configuration does not claim a verified kill switch.

### What changes when you add a second VPN?

Usually a new provider config/ciphertext and profile entry. Keep names unambiguous, avoid simultaneous competing default routes, choose autoconnect explicitly, and connect one at a time until you understand the routing. Reuse the existing age identities.
