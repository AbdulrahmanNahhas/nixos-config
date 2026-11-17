# 06 — The consent gate

Some menu actions need an explicit yes. Return a decision about whether consent
is still needed, without running anything or changing the catalog's safety rule.

**Edit, relative to the learning root (`learn-rust/`):**
[`chapters/03-safe-actions/06_confirmation.rs`](06_confirmation.rs).
Keep `authorize(action: &Action, consent: bool) -> Decision` and the supplied
`Decision` variants, `Ready` and `NeedsConfirmation`.
[Action](../../support/action.rs) is supplied starter vocabulary, not a final
production permission model.

## Contract

| `action.confirm` | `consent` | Returned decision   |
| ---------------- | --------- | ------------------- |
| `false`          | `false`   | `Ready`             |
| `false`          | `true`    | `Ready`             |
| `true`           | `false`   | `NeedsConfirmation` |
| `true`           | `true`    | `Ready`             |

Do not mutate the action or remember consent between calls. After authorizing a
protected action with consent, its `confirm` flag must still be `true`; a later
call without consent must return `NeedsConfirmation` again.

Both variants are data. `Ready` does not execute a command, launch a subprocess,
open a GUI or prove production safety. There is no prompt to implement here;
`consent` is already supplied by the caller.

**Predict before editing:** Can an action that needs no confirmation be ready
when consent is false? What should a second call do if consent changes to false?

## Check, then explain

```sh
menu-quest check 06-confirmation
menu-quest quiz 06-confirmation
menu-quest review 06-confirmation
```

Explain each decision and why a one-call approval must not remove the catalog's
confirmation requirement. Discuss it in chat; `review` only prints prompts and
passing tests does not automatically approve or authorize a production migration.

Reference: [The Rust Book — Defining an Enum](https://doc.rust-lang.org/book/ch06-01-defining-an-enum.html).
