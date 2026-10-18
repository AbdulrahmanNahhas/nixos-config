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

## Device access follows the desktop session

The personal account no longer has permanent `input`, `audio`, `video` or `dialout` membership. logind and udev mediate seat-device access for the active graphical session; applications normally use PipeWire for audio. Raw input-group access can expose keyboard events, and serial devices are not needed by the declared laptop workflows. GPU rendering, GameMode and OpenRazer retain their declared groups. This reduces standing privileges; active-session device ACLs and privileged services still need their own review.

Existing processes keep their supplementary groups until a fresh login. After activation, fully log out and back in, then check `id` in a new terminal and test Niri input, audio input/output, GPU offload, Steam controllers and Polychromatic. A missing serial workflow should receive a device-specific rule after identifying the hardware, rather than restoring blanket `dialout` access.

## Boot trust is a separate layer

Secure Boot and TPM auto-unlock are not configured by these stages. Secure Boot signs/verifies boot artifacts; it does not replace disk encryption. TPM unlock links access to measurements/policy and needs a recovery credential. NVIDIA and OpenRazer complicate module-signing/lockdown decisions. Enrollment belongs to a prepared recovery exercise, not a quick cleanup.

The previously exposed Wallhaven token still requires provider-side rotation if that has not already happened. A clean current-source scan cannot prove it was revoked or that old Git history contains no secrets.
