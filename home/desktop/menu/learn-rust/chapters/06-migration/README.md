# Chapter 06 — Opt-in migration

**Future brief only.** No migration is implemented or authorized by this chapter.
There are no runnable levels or stub puzzles here. Completing Menu Quest does not
replace the live menu, install a binary or activate a NixOS configuration.

## Outcome

If the user explicitly chooses to proceed, assess a staged Rust integration that
preserves the existing menu design, public command names and behavior, with a
reviewable rollback path. The user may instead keep the learning project separate.
That is a valid outcome, not a failed campaign.

## Compatibility that must survive

Current source is authoritative. Review these owners before proposing changes:

| Owner                                                                        | Boundary to preserve                                                                                                                       |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| [Nix wiring](../../../default.nix)                                           | `shadow`, `desktop-menu` and `wallpaper-tag` command names and their existing entry-point behavior.                                        |
| [Dispatcher](../../../shadow.nu)                                             | Existing subcommands, argument handling and confirmation boundaries.                                                                       |
| [Native Rofi mode](../../../rofi-mode.c) and [theme](../../../desktop.rasi)  | Same native-mode protocol, design, navigation, icons and search; see the [Rofi brief](../04-rofi/README.md).                               |
| [Native GIO helper](../../../apps.c) and [app integration](../../../apps.nu) | Preserve the helper and its desktop-app semantics: precedence, visibility, Exec expansion and D-Bus launching remain GIO's responsibility. |

Do not replace desktop-file handling with a simplistic Rust parser or shell
command split. Do not turn starter command plans into an executor merely to make
a migration look complete. New execution paths need their own explicit design
and review, including consent and cancellation.

## Proposed stages, only after explicit opt-in

1. **Agree on scope.** Identify one component to replace and what remains native
   or Nushell. Record compatibility expectations and how to return to the current
   implementation. Do not assume a total rewrite is desirable.
2. **Compare without cutover.** Use fixture/protocol tests and an explicitly agreed
   non-destructive preview beside the existing implementation. Keep production
   entry points unchanged. Inspect both results and errors.
3. **Review wiring and rollback.** Propose the smallest production diff. Preserve
   command names and the native GIO helper. Exclude lesson sources and generated
   learning state from production source packaging; the current wrapper references
   the whole menu directory. Get explicit permission for any live effect; a
   learning review acknowledgement is not that permission.
4. **Validate the proposed production change.** Follow the repository's
   [root rules](../../../../../../AGENTS.md): `nix flake check`, `git diff --check`
   and `nh os build /saved/nixos-config` for configuration changes. Review the
   relevant compatibility tests too. A successful build does not authorize
   activation. Any requested temporary activation uses the root workflow.
5. **Accept on the host.** With permission, verify the unchanged visuals,
   navigation, search, application launching, consent and cancellation behavior,
   plus the agreed rollback. Do not run destructive actions merely to test them.
   Record only checks actually observed; unresolved differences remain open.

Host acceptance and an agreed reversible cutover are future completion criteria,
not a claim that a build or the six starter levels satisfy them. Keep any actual
production migration in a separately requested change; do not perform it while
working through this documentation or the starter exercises.

## References

- [Campaign](../../CAMPAIGN.md) and [tutor safety rules](../../../AGENTS.md).
- [Reversible-state brief](../05-state/README.md) for fixture-first restoration.
- [Rust Book](https://doc.rust-lang.org/book/) and
  [standard library](https://doc.rust-lang.org/std/) for language/API review.
