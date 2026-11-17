# 02 — Put a label on it

A menu needs readable action labels. Accept a borrowed application name and make
an owned label, without changing the name you were given.

**Edit, relative to the learning root (`learn-rust/`):**
[`chapters/01-launchpad/02_labels.rs`](02_labels.rs).
Keep `action_label(name: &str) -> String`.

## Contract

Prefix the name with exactly `Open ` (one trailing space). Preserve every input
character, including Unicode and whitespace; do not trim or normalize it.

| Input          | Returned `String`   |
| -------------- | ------------------- |
| `"Ghostty"`    | `"Open Ghostty"`    |
| `"読書 📚"`    | `"Open 読書 📚"`    |
| `"two  words"` | `"Open two  words"` |
| `""`           | `"Open "`           |

The result must remain usable after the caller's input `String` is dropped.
Return data only; do not open an application.

**Predict before editing:** Why can the input be `&str` while the output needs to
be owned? What should happen for an empty name?

## Check, then explain

```sh
menu-quest check 02-labels
menu-quest quiz 02-labels
menu-quest review 02-labels
```

Explain in chat who owns the input and output, and why the output can outlive the
input. `review` prints prompts; it does not approve the level.

Reference: [The Rust Book — The Slice Type](https://doc.rust-lang.org/book/ch04-03-slices.html)
for string slices and their relationship to `String`.
