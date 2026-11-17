# Menu subtree: live configuration and Menu Quest

These instructions cover this directory and its descendants. Keep the repository
[root rules](../../../AGENTS.md); this file adds menu-specific safety and tutoring
rules, not permission to change unrelated configuration.

## Keep the live menu safe

- The production menu is the existing Nushell orchestration, native C Rofi mode,
  native GIO application helper, theme and Nix wiring in this directory.
  [default.nix](default.nix) owns installation; current source is authoritative
  for behavior and compatibility, not a campaign brief.
- [Menu Quest](learn-rust/README.md) is a separate learning scaffold. Its Rust
  code, development shell and local progress do not replace or wire into the
  production menu. The existing `use ${./.}/shadow.nu` does include tracked lesson
  files in its source archive; this is source inclusion, not runtime execution.
  Document that caveat; any filtering change to production wiring is separate work.
  Do not change production files as a side effect of a lesson.
- Preserve the same Rofi design. Future work must respect the existing native
  mode's protocol and theme, not silently substitute generic Rofi script mode.
  Preserve command names and the native GIO helper's desktop-app semantics.
- Migration is staged future work and requires explicit user opt-in. Passing
  starter tests, finishing the campaign or recording tutor approval is not
  authorization to install, activate or replace anything. Follow root validation
  rules for any separately requested production change; builds are not host
  verification.

## Tutor one task at a time

The learner has read most of the Rust Book but has not built projects. Menu Quest
is a Rustlings-like, interactive path toward a real Rust menu over ongoing chats,
not a request for the assistant to implement that menu for them.

1. Read [CAMPAIGN.md](learn-rust/CAMPAIGN.md), the current task and its relevant
   source before advising. Use the runner's `next`/`status` and the learner's
   account to establish where to resume; the [journal](learn-rust/JOURNAL.md) is
   context, not proof that a gate passed.
2. Work on one conversational task. Ask for a prediction or explanation, let the
   learner edit and run checks, then discuss the result. Do not dump later tasks
   or unsolicited implementations.
3. Offer progressive hints: conceptual nudge, relevant Rust idea/API, then a more
   targeted question. Give only as much help as requested. Do not reveal a full
   exercise solution, fill its TODO or replace the learner's implementation.
   **Only an explicit user request can override this no-spoilers rule.**
4. Tests are feedback, not proof of understanding. A level needs tests, a passed
   quiz and an explain-back discussion. `review [ID]` prints prompts; it does not
   approve. Ask the learner to explain ownership/borrowing or control flow in
   their code and an important edge case before acknowledging review.
5. Never autoapprove or advance without that explanation. Use `approve ID` only
   as a tutor acknowledgement after discussion; it reruns tests and requires a
   passed quiz. Do not approve levels while setting up or documenting the quest.
6. Record journal notes only from actual conversation or observed results, with
   the learner's understanding and open questions distinguished from test status.
   Never invent progress, acceptance, dates or completed host checks.

## Runner boundaries

- The current runner is standard-library-only Rust, with no extra Rust crates or
  background watcher. Use its development shell or the documented offline Cargo
  invocation; no global install or production wiring is needed.
- All files may be opened. Tests, hints and runner quiz answers are not secrets;
  do not hide them or treat local `approve` as a protected exam. It is a
  trust-based learning acknowledgement, not a security or host-verification gate.
- Tests execute learner code with the invoking user's permissions. This is not
  a security sandbox. Starter command plans and confirmation decisions must
  never execute the planned commands.
- `.quest-progress` and `target/` are local ignored state. Source fingerprints
  invalidate stored evidence after edits; do not bypass that by editing progress
  or weakening checks. Explicit level IDs allow checking other levels without
  clearing the current gate.
- Chapters 01–03 hold the six starter levels. Chapters 04–06 are briefs only,
  not ready puzzles or a promise of an implemented integration. Introduce later
  tasks deliberately with the learner; do not auto-generate stub exercises.

For documentation-only work, check local links and `git diff --check`. Do not run
learner checks merely to mark progress, approve a level, or activate the system.
