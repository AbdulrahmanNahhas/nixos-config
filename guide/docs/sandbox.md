{
"title": "Understand app permissions",
"group": "DAILY WORK",
"weight": 8,
"sources": [
[
"Flatpak sandbox permissions",
"https://docs.flatpak.org/en/latest/sandbox-permissions.html"
],
[
"Flatpak command reference",
"https://docs.flatpak.org/en/latest/flatpak-command-reference.html"
]
],
"build": {
"render": "link",
"list": "always"
}
}

Flatpak separates an application from much of the host, then grants capabilities. Filesystems expose paths; sockets expose display/audio interfaces; devices expose hardware; shared namespaces permit networking or IPC; D-Bus policy permits named services. Every grant should match a task the app needs.

`xdg-download:ro` gives read-only Downloads access. Without `:ro`, a filesystem grant normally permits writing. `dri` exposes graphics devices. The managed catalog has no unrestricted `all` device exception. Impression uses its upstream UDisks2 interface for image writing; Signal has GPU access instead of access to every device. Direct V4L2 webcam access is consequently unavailable to Signal under this policy; camera support requires a tested mediated implementation. An XWayland exception trades isolation for compatibility.

Heroic has a scoped X11/shared-IPC exception for Wine games, plus GPU and input-device access for rendering and controllers. Its reviewed filesystem list keeps the default game library inside its persistent sandbox home and permits read-only udev metadata. The Flatpak lesson describes that storage choice; this declaration does not establish compatibility with every game or controller.

## Two different filesystem policies

Denying `host` and `home` removes those broad grants. It does not remove narrower inherited permissions such as Documents. Every managed application now receives a filesystem reset before its explicit catalog allowlist, including read-only GTK theme paths. An upstream manifest update therefore cannot silently add another static filesystem path. Reviewed runtime endpoints for speech, GVfs and PipeWire are declared beside the apps that use them. Application-private storage and approved document-portal grants are separate from this static list.

Explicit denials also cover `/saved`, `/run/secrets`, SSH/GPG/cloud credentials, raw keyring storage and selected application credentials. The `/saved` denial closes the alternate backing-store route to retained home data. Raw keyring/SSH/GPG-agent sockets and unfiltered session/system buses are denied; named filtered D-Bus grants, including Element's Secret Service integration, remain deliberate exceptions. User overrides can still supersede system policy and must be reviewed after activation.

Secret Service and KWallet names are denied by default, including when an upstream manifest requests them. Element explicitly re-enables Secret Service in its catalog entry. A new credential-service grant requires its own review; raw file denials alone would not prevent a service from returning a secret.

The isolation pass checked every installed app's merged permissions with Flatpak 1.18.4 against the generated catalog allowlists. A shell-only launch with synthetic home data and a private D-Bus session confirmed that SSH, persistent backing paths and SOPS runtime credentials were inaccessible. The private test environment could not mount the document portal because its synthetic `/dev` had no FUSE device; file dialogs, media calls and image writing still require normal desktop acceptance after activation. No personal application data was used in that test.

A **portal** lets the desktop mediate a request, such as selecting a file or sharing a screen. Granting a directory permanently is different from selecting a file through a portal. Previously granted portal access can outlive a single dialog. A network permission is usually all-or-nothing, not a domain allowlist.

### Why not block everything globally?

Apps can fail before showing a helpful error: missing GPU access, incompatible Wayland support, camera access, or document paths. Reduce capabilities deliberately, test the actual task, and keep an explicit exception when needed. Isolation must remain understandable.

### What about native apps and AppImages?

Native apps do not become sandboxed merely because Nix installs them. AppImage compatibility also does not itself confine an app. They run with their process’s normal user permissions unless another sandbox or enforced policy applies.
