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

`xdg-download:ro` gives read-only Downloads access. Without `:ro`, a filesystem grant normally permits writing. `dri` exposes graphics devices. `all` is much broader and is retained for specific apps requiring direct device access. An XWayland exception trades isolation for compatibility.

## Two different filesystem policies

Denying `host` and `home` removes those broad grants. It does not remove narrower inherited permissions such as Documents. A filesystem reset removes inherited path grants before rebuilding the intended allowlist. Per-app policy needs testing; some applications use portals well, while others expect direct folders.

A **portal** lets the desktop mediate a request, such as selecting a file or sharing a screen. Granting a directory permanently is different from selecting a file through a portal. Previously granted portal access can outlive a single dialog. A network permission is usually all-or-nothing, not a domain allowlist.

### Why not block everything globally?

Apps can fail before showing a helpful error: missing GPU access, incompatible Wayland support, camera access, or document paths. Reduce capabilities deliberately, test the actual task, and keep an explicit exception when needed. Isolation must remain understandable.

### What about native apps and AppImages?

Native apps do not become sandboxed merely because Nix installs them. AppImage compatibility also does not itself confine an app. They run with their process’s normal user permissions unless another sandbox or enforced policy applies.
