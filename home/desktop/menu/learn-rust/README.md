# Menu Quest

You've read most of the Rust Book. Now build something, one small win at a time.
Menu Quest is a Rustlings-like terminal game for learning to build a real Rust
menu with the **same Rofi design** as this desktop. No project experience needed.
The [live menu](../default.nix) stays untouched: this is a separate learning area,
not a replacement installed into your session.

Packaging caveat: the existing Nix wrapper references the entire menu directory.
Once tracked, lesson sources can therefore enter its source archive and cause
rebuilds when edited, although they are not executed. Git-flake builds exclude
ignored build/progress files; unfiltered filesystem builds may not. Filtering
that production source is separate future wiring work, not part of a lesson.

## Start from the repository root

```sh
nix-shell home/desktop/menu/learn-rust/shell.nix
menu-quest play
```

The development shell uses the root lock's pinned nixpkgs and supplies Cargo,
`rustc`, `rustfmt`, Clippy, `rust-analyzer` and a `menu-quest` command wrapper.
Nothing is installed globally or wired into production. Nix may need initial
network downloads or builds; the first launch can take longer.

Already have the Rust tools installed? Run a command directly instead:

```sh
cargo run --offline --manifest-path home/desktop/menu/learn-rust/Cargo.toml -- next
```

Replace `next` after `--` with any command below. The current runner uses only
Rust's standard library, with no extra crates and no background watcher.

## Your first turn

1. Start `play`, or run `menu-quest next` to see the current task and edit target.
2. Read the task, make a prediction, then edit only that exercise's learner code.
3. Run `menu-quest check`. **The initial `todo!()` failure is expected**, not a
   broken setup. Read the failure, adjust your code and try again.
4. Take `menu-quest quiz`, then use `menu-quest review` for explain-back prompts.
5. In chat, explain your code and an edge case. Your tutor acknowledges review
   with `approve ID` only after that discussion. Then ask for the next task.

You can start a later chat with: “Resume Menu Quest. Let's look at my current task
and what I understand so far.” One task at a time; ask for a hint whenever useful.
The mentor's [ground rules](../AGENTS.md) keep solutions yours unless you explicitly
ask for a spoiler.

## Controls and commands

Run these in the development shell; `play` provides the interactive terminal
loop. Follow its prompts. `Ctrl+C` interrupts the running terminal command; resume
with `play` or `next`. Bare `menu-quest` defaults to `next`, not `play`.

| Command                                 | Purpose                                                                          |
| --------------------------------------- | -------------------------------------------------------------------------------- |
| `menu-quest play`                       | Interactive terminal session.                                                    |
| `menu-quest list` / `menu-quest status` | See levels and recorded gate status.                                             |
| `menu-quest next`                       | Show the next uncleared level.                                                   |
| `menu-quest task [ID]`                  | Read the current task, or a named level.                                         |
| `menu-quest check [ID]`                 | Run that level's tests.                                                          |
| `menu-quest quiz [ID]`                  | Answer the quiz interactively.                                                   |
| `menu-quest quiz ID A`                  | Submit choice A noninteractively for an explicit level.                          |
| `menu-quest hint [ID] [1\|2\|3]`        | Request progressively stronger hints.                                            |
| `menu-quest review [ID]`                | Print explain-back prompts; this does **not** approve.                           |
| `menu-quest approve ID`                 | Tutor acknowledgement after discussion; reruns tests and requires a passed quiz. |
| `menu-quest help`                       | Show command help.                                                               |

Square brackets mean optional arguments; do not type the brackets. Find exact IDs
with `list` (the first is `01-greeting`). Explicit IDs let you inspect or check
other levels without clearing the current one.

## Progress without pressure

Each level has three gates: **tests, quiz, review**. All must be satisfied before
the next level clears. A wrong quiz answer has no penalty, XP loss or score;
revisit the idea and retry. Passing tests alone does not prove understanding.

Progress resumes from local ignored `.quest-progress`; Cargo output lives in the
ignored `target/` directory. Changes to exercise source, checks, task contracts,
quiz content or review questions invalidate stored evidence via a fingerprint;
recheck status after editing and repeat the affected gates. Mutating commands
use an OS lock: a concurrent update is refused rather than overwriting progress.
The ignored `.quest-progress.lock` file can remain; its lock releases on exit.
[The journal](JOURNAL.md) is an optional human handoff for questions and discussion,
not the runner's progress database. Local approval is trust-based, not a protected
exam or evidence that anything works on the host. You may open every file;
hints, tests and runner answers are not secrets.

**Tests execute your code, with your permissions. This is not a security sandbox.**
The starter tasks only build data and decisions: they must not execute planned
menu actions. Do not add real shutdown, rebuild or other live actions to a lesson.

## If something gets stuck

- `menu-quest: command not found`: enter the development shell from the repository
  root, or use the full Cargo command above. The wrapper exists inside the shell.
- Missing `cargo`/`rustc`: use the shell. If `nix-shell` itself is missing, you need
  an available Nix installation or an existing Rust toolchain for the alternative.
- Nix fetch/build failure: inspect that error first; initial provisioning may
  need network access. Cargo's `--offline` does not make Nix provisioning offline.
- A panic mentioning `todo!()` is the intended first exercise failure. A compiler
  error is also feedback; bring its first relevant diagnostic to the chat.
- Unsure why progress changed? Run `status` and `task`; edits can invalidate old
  evidence. Do not edit the progress file to skip a gate.

## Maintaining the runner

This is different from solving a level. From the learning directory, with its
Nix shell active:

```sh
cargo test --offline
cargo clippy --offline --all-targets -- -D warnings
cargo fmt -- --check
```

Runner self-tests use temporary synthetic fixtures, not completed learner
solutions, and never approve your real progress. One self-test deliberately
exercises failing tests and invalid Rust; its child diagnostics are expected
when the overall self-test suite finishes successfully. The six learner checks
are separate: `cargo test` passing does not mean a level is solved.

For isolated runner smoke tests, `MENU_QUEST_PROGRESS` can point to a disposable
progress file. Normal play needs no environment variables. Keep generated files
under ignored `target/`; do not add answer keys to the exercise directory.

## Where this leads

[CAMPAIGN.md](CAMPAIGN.md) maps six chapters: three starter chapters with six
levels, then briefs for Rofi, reversible state and an explicitly opted-in
migration. Future briefs are not ready exercises. There is no deadline and no
automatic production cutover.

Keep the [Rust Book](https://doc.rust-lang.org/book/) and
[standard library documentation](https://doc.rust-lang.org/std/) nearby as
references, not another cover-to-cover prerequisite.
