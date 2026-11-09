# Major work

[Project guide](README.md) · [System and tools inventory](REFERENCES.md)

A checklist of substantial improvements and migrations. An unchecked item may
have configuration in place while host acceptance remains open. Completion means
meeting its criterion, including live tests where required. This list carries
forward existing work; it does not authorize activation, migration or enrollment.

## Recovery and reliability

- [ ] **Independent encrypted backup and restore.** Choose a destination,
      retention and recovery credentials; cover personal files, projects, important
      app state and recovery material. **Complete when:** selected files and keys can
      be restored without relying on Shadow. Restic/Borg remain options, not a decision.
- [ ] **Persistence migration and reboot acceptance.** Review the
      [retained state](system/storage/persistence.nix), migrate existing data before
      mounting, and verify service ownership and writes. Include Btrfs, SMART,
      power-profile state and the managed Nahhasio profile where migration is still
      needed. **Complete when:** relevant state survives reboot, a scrub completes,
      and a maintenance warning reaches the user. Recheck the host before assuming
      any previously recorded migration is still outstanding.
- [ ] **Repeatable update and rollback workflow.** Establish targeted input
      updates, separate Flatpak review, post-reboot checks and generation retention.
      Depends on independent recovery. **Complete when:** an update and rollback are
      rehearsed with a known-good generation still reachable.

## Power and hardware

- [ ] **Battery and suspend/resume acceptance.** Measure balanced and power-saver
      profiles under controlled brightness, refresh rate and workload. Check GPU
      suspension after offload, display disconnect and resume; test locking, networking,
      audio and unplugged suspend drain. **Complete when:** results are repeatable,
      responsiveness is acceptable, and the discrete GPU returns to suspension.
  Current blocker: the driver reports runtime D3 unsupported despite fine-grained
  power management; no supported fan-control interface was exposed in the audit.
      Trial another power backend only if this baseline demonstrates a gap.

## Security

- [ ] **Secure Boot evaluation and adoption decision.** After recovery and
      hardware acceptance, evaluate [Lanzaboote](https://nix-community.github.io/lanzaboote/),
      firmware recovery, ESP capacity and key management. **Complete when:** either a
      decision to defer is recorded, or signed boot, driver compatibility, rollback
      and independent key recovery are verified. Key enrollment is a separate action;
      TPM-based unlocking requires its own decision.
- [ ] **Session, sandbox and network protection review.** Verify fresh login,
      privilege escalation, keyring, portals, USB authorization and app permissions.
      Reassess workarounds against the current configuration; check VPN IPv4/IPv6
      routes and DNS when connected. **Complete when:** effective protections and
      required exceptions have reproducible checks, with a recovery path preserved.
- [ ] **Signal key-storage migration rehearsal.** Inspect the installed backend,
      back up the closed profile and keyring, and rehearse any required migration
      separately. **Complete when:** existing messages survive two launches and a
      reboot using the intended backend, with a usable rollback. Never reset the
      existing profile to make a migration succeed.

## Desktop transition

- [ ] **Accept the revised login and desktop stack on the host.** Verify the
      Noctalia greeter and cursor, both Niri and secondary Umbriel sessions, keyring
      unlock, lock/wake, application launchers, Firefox
      profiles, wallpaper controls, portals, native Flatpak font/icon discovery and screen recording. **Complete when:**
      a fresh login and reboot succeed, desktop controls work, and two consecutive
      recordings save and play. Repository build success alone is insufficient.

## Completed structure

- [x] **Simplify the repository around `system/` and `home/`.** Explicit root
      entry files replace the previous composition folders; editors and applications
      share `home/apps/`. Configuration evaluation and the no-link system build passed.
      This records source organization, not host activation.

Routine app additions and replacements belong in the [inventory](REFERENCES.md).
Add a roadmap item only when the work is a substantial agreed transition, with a
clear outcome. Disabled experiments are recorded there without a promise to adopt.
