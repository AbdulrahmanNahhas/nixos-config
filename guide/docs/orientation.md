{
"title": "Start with the whole system",
"group": "FOUNDATIONS",
"weight": 1,
"sources": [
[
"NixOS manual",
"https://nixos.org/manual/nixos/stable/"
],
[
"nix.dev learning paths",
"https://nix.dev/"
]
],
"build": {
"render": "link",
"list": "always"
}
}

**The goal**

### Explain it, then change it.

Read the foundational topics once. Afterward, use global search by task: add an app,
rotate a token, recover a generation, or debug DNS. Press `/` or `Ctrl+K` / `Cmd+K`
from any page. Results open the relevant topic, technology, roadmap item, history
card or configuration file. Review marks are stored only in your browser.

**The boundary**

### Source is not the running system.

This guide describes the repository. Settings become active only after activation;
boot changes may require a reboot. The guide does not execute commands or change
your machine. The Configuration tree describes source relationships; Build details
contains pinned input revisions. Neither establishes runtime health.

## What the names mean

**Nix** is a package manager and expression language. **Nixpkgs** is a package collection and library. **NixOS** uses Nix to describe an operating system. **Home Manager** describes your user environment. A **flake** gives the project inputs and named outputs. **devenv** gives each development project its own tools and services.

A laptop has more than one kind of state: configuration source, installed software, running services, personal data, credentials, and firmware. Nix describes much of the first three. It does not turn your documents, databases, or firmware settings into rollback-safe Nix values.

## Your system’s shape

```
flake.nix → shadow/default.nix → modules/nixos/
                              → shadow/home.nix → modules/home/
encrypted-secrets/ → sops-nix → protected files in /run
guide/ → this offline learning interface
```

Shadow is one Razer Blade 14 with AMD integrated graphics and NVIDIA graphics, Niri and Noctalia on Wayland, a tmpfs root, and LUKS-encrypted Btrfs storage. Hardware facts live in `shadow/`; reusable capabilities live in modules.

> The important habit: locate the owner of a behavior, edit its source, evaluate, build, test, then activate. Do not begin by editing generated files under /etc or the Nix store.
