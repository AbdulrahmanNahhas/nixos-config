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
"Agent sandbox and approvals",
"https://learn.chatgpt.com/docs/agent-approvals-security"
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

Kernel crash dumps are discarded through `kernel.core_pattern`, with systemd-coredump disabled. Disabling the systemd handler alone is insufficient: the pinned NixOS module falls back to a `core` file in the crashing process's working directory. The discard helper prevents that fallback from saving process memory, including credentials and decrypted documents. Debugging with saved crash dumps requires a deliberate temporary policy change. This does not erase existing dumps or control an application's own crash-report files. Linux documents the pipe-handler behavior in its [core_pattern reference](https://docs.kernel.org/admin-guide/sysctl/kernel.html#core-pattern).

The `fs.protected_regular` and `fs.protected_fifos` policies extend sticky-directory protections to group-writable directories as well as world-writable ones. They constrain certain opens of files owned by other users, reducing temporary-file substitution attacks; an old script relying on those opens may need repair. The [kernel filesystem reference](https://docs.kernel.org/admin-guide/sysctl/fs.html) explains their exact scope.

## Shell-history privacy

Atuin's history search remains available locally. Automatic sync and independent update checks are disabled declaratively; Nix owns package updates. Manual `atuin sync` remains possible, and previously uploaded history is not deleted. The built-in secret-pattern filter is explicitly enabled, but only recognizes supported formats and does not remove earlier entries. Keep secrets out of command arguments and history. The configuration and data directories, including sync identity and encryption keys, use mode `0700`. This does not constrain other programs running as Aqua. See [Atuin's configuration reference](https://docs.atuin.sh/18.17/configuration/config/) for the settings and limitations.

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

The ChatGPT desktop app and Codex CLI use their built-in sandbox and approval controls. This configuration no longer installs a system-managed `/etc/codex/requirements.toml`. The additional policy was retired after repeated Bubblewrap startup failures blocked development commands, including approved commands. Isolated checks of a filename-glob repair did not establish recovery in the affected desktop session. Do not create persistent credential directories merely to satisfy sandbox mount targets.

Use the workspace sandbox with approvals for normal development. Grant additional access deliberately when Git, Nix development environments or GTK application workflows need it. Removing the managed policy does not disable the client's sandbox, but does remove our extra credential-read denials and enforced profile restrictions. Workspace write restrictions are not a promise that all readable credentials in the account are hidden. Client permission settings remain a runtime choice; verify the selected mode in each session.

After activating this removal, fully quit and reopen the desktop app so its execution environment is recreated. Verify ordinary Git reads and the approved command path in the affected project. Build validation alone does not establish that the live session recovered. Review `.envrc`, devenv trust, extensions and build scripts before enabling them. For unfamiliar code that needs broader execution, use a separate development user or disposable VM without personal credentials. Ordinary terminals, language servers and separate MCP processes require their own trust decisions.

Zed has a declared non-setuid Bubblewrap dependency for its built-in agent sandbox. That sandbox restricts terminal writes/network access and protects Git metadata, but allows filesystem reads and does not cover external agents, extensions, language servers or ordinary terminals. Private-value redaction is enabled for visual privacy; it is not a read prohibition or a promise that content cannot be sent to a provider.

Retiring the managed policy changes no persistent secret stores. Existing SSH, keyring, agent and SOPS persistence remains owned by the persistence module.

## Boot trust is a separate layer

Secure Boot and TPM auto-unlock are not configured by these stages. Secure Boot signs/verifies boot artifacts; it does not replace disk encryption. TPM unlock links access to measurements/policy and needs a recovery credential. NVIDIA and OpenRazer complicate module-signing/lockdown decisions. Enrollment belongs to a prepared recovery exercise, not a quick cleanup.

The previously exposed Wallhaven token still requires provider-side rotation if that has not already happened. A clean current-source scan cannot prove it was revoked or that old Git history contains no secrets.
