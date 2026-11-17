# 05 — Plan, don't launch

Turn an action into an owned description that could be inspected later. Your job
is validation and data conversion, **never command execution**.

**Edit, relative to the learning root (`learn-rust/`):**
[`chapters/03-safe-actions/05_command_plan.rs`](05_command_plan.rs).
Keep `plan(action: &Action) -> Result<CommandPlan, &'static str>` and the supplied
`CommandPlan` (`program: String`, `args: Vec<String>`).
[Action](../../support/action.rs) is supplied starter vocabulary.

## Contract

- If the program is empty or whitespace-only, return exactly
  `Err("program must not be blank")`. Examples: `""`, `" "`, `"\t\n"`.
- Use trimming **only to validate blankness**. For a nonblank program, return
  `Ok` with an owned plan preserving the original program text exactly:
  `" tool "` stays `" tool "`, and `"/example path/tool"` stays unchanged.
- Copy every argument into owned storage, preserving order, text and boundaries.
  `""`, `"two words"`, `"a;b"`, `"$(example)"`, `"\"quoted\""` and `"読書 📚"`
  are literal data, not shell syntax. Do not split, join, escape or interpret them.
- An empty argument list is valid. Do not check installation or filesystem
  existence: `"not-an-installed-program"` is a valid nonblank program here.
- Borrow the action without changing it. Do not spawn a process or start a GUI.

For program `"noctalia"` and arguments `"msg"`, `"settings-open"`, success contains
that program and those two arguments, each owned. It does not open Settings.

**Predict before editing:** Which inputs should fail? Why would storing a trimmed
nonblank program or joining arguments change the requested command description?

## Check, then explain

```sh
menu-quest check 05-command-plan
menu-quest quiz 05-command-plan
menu-quest review 05-command-plan
```

Explain the validation/preservation distinction, owned output and one argument
edge case in chat. `review` prints prompts; it does not approve the level.

References: [The Rust Book — Recoverable Errors with Result](https://doc.rust-lang.org/book/ch09-02-recoverable-errors-with-result.html)
and [standard library `str::trim`](https://doc.rust-lang.org/std/primitive.str.html#method.trim).
