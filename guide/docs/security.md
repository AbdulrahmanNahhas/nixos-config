{
"title": "Security without magic labels",
"group": "NETWORK & PROTECTION",
"weight": 14,
"sources": [
[
"AppArmor project",
"https://apparmor.net/"
],
[
"systemd service sandboxing",
"https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html"
],
[
"Lanzaboote recovery considerations",
"https://nix-community.github.io/lanzaboote/explanation/troubleshooting.html"
],
[
"Managed agent configuration",
"https://developers.openai.com/codex/enterprise/managed-configuration"
],
[
"Zed agent sandboxing",
"https://zed.dev/docs/ai/sandboxing"
]
],
"build": {
"render": "link",
"list": "always"
}
}

LUKS protects retained data while the disk is locked. It does not block malware running as you after login. SOPS protects selected secrets in Git/store copies, but applications consuming them can read them. An ephemeral root removes undeclared root state after reboot, while preserved histories and app profiles remain.

USBGuard controls USB device authorization. Its built-in allowlist is essential: blindly blocking those devices can break the keyboard, camera, and Bluetooth. This configuration supplies an immutable declarative policy: `usbguard allow-device <id>` approves temporarily, while permanent approvals must be added to `services.usbguard.rules`. The `-p` IPC flag cannot write the Nix-store policy. Review a device before allowing it.

AppArmor is loaded, but useful protection requires enforced profiles that cover actual workloads. A native app without a profile is not magically confined. Service hardening can restrict writable paths, devices, namespaces, privileges, and address families. Add restrictions with the service’s data and workflow in mind.

## Authentication and session details

Root password login is locked; Aqua authenticates with a SOPS-deployed hash and has administrative access through sudo-rs. The greetd login stack unlocks the GNOME keyring. A documented workaround bypasses the nested user-manager PAM call after a deadlock; it must be investigated through actual session tests before removing it.

Niri/Noctalia supplies idle locking and suspend behavior. Locking before suspend must be tested interactively. An unlocked keyring can serve credentials to authorized apps; secret-service access should be granted intentionally.

Managed Flatpaks are denied Secret Service and KWallet access by default. Element explicitly retains its Secret Service integration because it uses the login keyring. Such an application remains trusted to request credentials through that service; hiding raw keyring files does not constrain what the service supplies. Signal's current basic database-key backend does not need this service grant. Its installed launcher warns that changing to an encrypted backend can cause data loss, so the roadmap requires a protected backup and migration rehearsal before enabling the keyring backend and its corresponding service permission.

## Device access follows the desktop session

The personal account no longer has permanent `input`, `audio`, `video` or `dialout` membership. logind and udev mediate seat-device access for the active graphical session; applications normally use PipeWire for audio. Raw input-group access can expose keyboard events, and serial devices are not needed by the declared laptop workflows. GPU rendering, GameMode and OpenRazer retain their declared groups. This reduces standing privileges; active-session device ACLs and privileged services still need their own review.

Existing processes keep their supplementary groups until a fresh login. After activation, fully log out and back in, then check `id` in a new terminal and test Niri input, audio input/output, GPU offload, Steam controllers and Polychromatic. A missing serial workflow should receive a device-specific rule after identifying the hardware, rather than restoring blanket `dialout` access.

## Credential reads by development agents

`modules/nixos/security/agent-policy.nix` generates `/etc/codex/requirements.toml`, a system-owned policy for supported local clients. Its default is the workspace permission profile, and the selectable profiles are workspace and read-only. Managed read denials cover SSH/GPG/cloud identities, package-manager credentials, browser/app credential stores, agent authentication/config files, Wi-Fi profiles and decrypted SOPS secrets. Home paths and their `/saved/home` backing aliases are both covered. Mutable user settings and repository configuration cannot weaken these managed read denials in supported execution paths.

The policy does not contain credentials and does not modify the mutable `~/.codex/config.toml`. Authentication is performed by the client outside its command sandbox; this policy restricts agent execution. Confirm support for every client version independently, including bundled desktop and ACP runtimes. With the installed CLI 0.162.1, isolated tests allowed source reads and workspace writes while denying synthetic SSH and SOPS credentials, including backing paths and the runtime symlink. A local server inspection confirmed that a full-access request resolves to a workspace-write sandbox with networking disabled. The legacy CLI mode selector is constrained alongside the modern profile selector. Existing sessions must be restarted to load the policy.

This is a scoped agent control. It does not sandbox an ordinary terminal, a language server, OpenCode, a separate MCP process or code you later run yourself. Project `.env` files, secrets already exported into the environment and credentials supplied by separate services are not covered by this fixed credential-path list. Review `.envrc`, devenv trust, extensions and build scripts before enabling them. Use a disposable VM without personal credentials for unfamiliar code that needs broader execution; read-denial policy is not a substitute for that separate environment.

Zed has a declared non-setuid Bubblewrap dependency for its built-in agent sandbox. That sandbox restricts terminal writes/network access and protects Git metadata, but allows filesystem reads and does not cover external agents, extensions, language servers or ordinary terminals. Private-value redaction is enabled for visual privacy; it is not a read prohibition or a promise that content cannot be sent to a provider.

The policy and its prerequisites add no persistent secret stores. Existing SSH, keyring, agent and SOPS persistence remains owned by the persistence module. Roll back the declarative policy through a reviewed generation if a legitimate credential workflow needs redesign; never copy private keys into a workspace to bypass a denial.

## Boot trust is a separate layer

Secure Boot and TPM auto-unlock are not configured by these stages. Secure Boot signs/verifies boot artifacts; it does not replace disk encryption. TPM unlock links access to measurements/policy and needs a recovery credential. NVIDIA and OpenRazer complicate module-signing/lockdown decisions. Enrollment belongs to a prepared recovery exercise, not a quick cleanup.

The previously exposed Wallhaven token still requires provider-side rotation if that has not already happened. A clean current-source scan cannot prove it was revoked or that old Git history contains no secrets.
