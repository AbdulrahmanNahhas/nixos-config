# 01 — First signal

Give Menu Quest its first line of identity. This mission is deliberately tiny:
make one supplied function return the right value before adding moving parts.

**Edit, relative to the learning root (`learn-rust/`):**
[`chapters/01-launchpad/01_greeting.rs`](01_greeting.rs).
Keep the supplied `greeting() -> &'static str` signature.

## Contract

- Return exactly `Shadow apprentice`, including capitalization and the space.
- No trailing newline or other extra characters.
- Return the text; printing it is not a substitute. No terminal input, subprocess
  or GUI is needed.

**Predict before editing:** What happens when the current `todo!()` is called?
What is the difference between returning this text and printing it?

## Check, then explain

```sh
menu-quest check 01-greeting
menu-quest quiz 01-greeting
menu-quest review 01-greeting
```

Bring your result to chat. Explain what the caller receives and why that string
reference can remain valid. `review` only prints prompts; tutor acknowledgement
comes after your explanation, not automatically after a green test.

Reference: [The Rust Book — Functions](https://doc.rust-lang.org/book/ch03-03-how-functions-work.html),
especially expressions and return values.
