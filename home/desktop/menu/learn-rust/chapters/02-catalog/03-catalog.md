# 03 — Two real menu entries

Build typed descriptions of Terminal and Settings. These names and commands come
from the current [production catalog](../../../catalog.nu), but your exercise
only returns data: it must not launch Ghostty or Noctalia.

**Edit, relative to the learning root (`learn-rust/`):**
[`chapters/02-catalog/03_catalog.rs`](03_catalog.rs).
Both `terminal_action() -> Action` and `settings_action() -> Action` are supplied.
Use the existing [Action type](../../support/action.rs); do not redefine it.

## Contract

Return an `Action` with these exact field values from each function:

| Field     | `terminal_action()` | `settings_action()`                                       |
| --------- | ------------------- | --------------------------------------------------------- |
| `id`      | `"terminal"`        | `"settings"`                                              |
| `label`   | `"Terminal"`        | `"Settings"`                                              |
| `program` | `"ghostty"`         | `"noctalia"`                                              |
| `args`    | Empty slice         | `"msg"`, then `"settings-open"` as two separate arguments |
| `confirm` | `false`             | `false`                                                   |

Keep argument order and boundaries; a single `"msg settings-open"` argument is
not equivalent. The supplied static strings/slices are starter vocabulary, not a
complete final production model. No spawning, shell command or GUI is needed.

**Predict before editing:** How is the stable `id` different from the visible
`label`? How many arguments does the Settings action contain?

## Check, then explain

```sh
menu-quest check 03-catalog
menu-quest quiz 03-catalog
menu-quest review 03-catalog
```

Explain in chat how the fields describe an action without performing it, and why
argument boundaries matter. `review` prints prompts; it does not approve.

Reference: [The Rust Book — Defining and Instantiating Structs](https://doc.rust-lang.org/book/ch05-01-defining-structs.html).
