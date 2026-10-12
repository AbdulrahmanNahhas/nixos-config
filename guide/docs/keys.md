{
"title": "Every key has a different job",
"group": "STATE & IDENTITY",
"weight": 10,
"sources": [
[
"age project and design",
"https://github.com/FiloSottile/age"
],
[
"SOPS documentation",
"https://getsops.io/docs/"
]
],
"build": {
"render": "link",
"list": "always"
}
}

| Identity          | Purpose                           | What is public?                             |
| ----------------- | --------------------------------- | ------------------------------------------- |
| LUKS credential   | Unlock encrypted disk storage     | Disk-format metadata, not the unlock secret |
| age identity      | Decrypt SOPS-encrypted material   | Recipient starting age1…                    |
| WireGuard key     | Authenticate a tunnel peer        | The corresponding VPN public key            |
| SSH key           | Authenticate SSH user or host     | The public SSH key                          |
| Cache signing key | Verify substituted Nix results    | The cache verification key                  |
| Secure Boot key   | Establish trusted boot signatures | Enrolled verification certificates          |

Your age setup has two independent private identities. Aqua’s editing identity is under `~/.config/sops/age/keys.txt`, backed by retained home state. Shadow’s deployment identity is `/saved/var/lib/sops-nix/key.txt`, protected for root. Their public recipients are in `.sops.yaml`.

SOPS encrypts each file’s data with a data key and wraps access for the configured recipients. In your setup either private identity can decrypt. Having two recipients is recovery redundancy, not a requirement to provide both keys together.

> Adding a VPN or token normally reuses the existing age recipients. The VPN may bring its own WireGuard key; that does not require a new age identity.

A public recipient is safe to commit, but authorizing it is a policy decision: it names an identity that may decrypt. Never paste an age private identity into chat, a shell argument, a Nix string, or Git. Back up at least the editing identity with independent encryption off the laptop. Encrypting its only backup to itself makes recovery circular.

### When do age identities change?

When an editing or machine identity is replaced, compromised, or newly authorized. Change the recipients, rewrap affected ciphertext with SOPS updatekeys, verify deployment, and rotate compromised provider credentials when necessary. An old private key may still decrypt old Git revisions.
