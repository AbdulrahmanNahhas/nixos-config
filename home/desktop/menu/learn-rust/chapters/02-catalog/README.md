# Chapter 02 — A catalog you can query

Move from text to typed actions. First describe two real menu entries, then look
up an entry by borrowing it. These are different jobs: constructing data and
finding existing data, not repeating the same implementation.

| Level                         | Mission                          | New piece                                            |
| ----------------------------- | -------------------------------- | ---------------------------------------------------- |
| [03 — Catalog](03-catalog.md) | Describe Terminal and Settings.  | Construct the supplied `Action` struct.              |
| [04 — Lookup](04-lookup.md)   | Find an action by its stable ID. | A slice, `Option` and a reference tied to its owner. |

Read the supplied [vocabulary](../../support/action.rs); its static fields keep
these first exercises focused. It is **starter vocabulary, not the complete final
production model**. Do not redesign the type or edit support/check files.

The examples come from the live [menu catalog](../../../catalog.nu): Ghostty for
Terminal and Noctalia for Settings. This chapter describes them without launching
anything. No starter check starts those applications or a GUI; keep learner code
free of subprocess execution too. The production menu stays untouched.

Use each task's explicit `check`, `quiz` and `review` commands. Explain the result
in chat before tutor acknowledgement; passing tests is not proof of understanding.
See [onboarding](../../README.md) to resume the shell and runner.
