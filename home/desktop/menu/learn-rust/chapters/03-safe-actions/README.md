# Chapter 03 — Decisions before effects

Describe a command, then decide whether it needs consent. Neither step performs
the action. Keeping those jobs separate makes safety rules easier to explain and
test before a real menu ever runs anything.

| Level                                   | Mission                                                 | New piece                                 |
| --------------------------------------- | ------------------------------------------------------- | ----------------------------------------- |
| [05 — Command plan](05-command-plan.md) | Validate a program and preserve its argv as owned data. | `Result`, `String` and `Vec<String>`.     |
| [06 — Confirmation](06-confirmation.md) | Decide whether consent is still needed.                 | An enum and a borrowed, unchanged action. |

Functions, `CommandPlan`, `Decision` and the shared
[Action vocabulary](../../support/action.rs) are supplied. These types are a
starter model, not the final production design. Edit only the task's exercise
file; no new type architecture or dependencies are needed.

**Do not execute command plans.** No starter check launches a planned subprocess
or starts a GUI, and learner code must not add those effects. The tests use
fixtures, including nonexistent program names; they test descriptions and
decisions, not whether software is installed. Tests execute learner code with
your permissions, not inside a security sandbox.

After each check and quiz, use `review` for prompts and explain your reasoning in
chat. Review does not approve automatically. Completing these levels is not
permission to alter the live menu. The [Rofi chapter](../04-rofi/README.md) is a
future brief, not a ready integration or an automatic next implementation.
