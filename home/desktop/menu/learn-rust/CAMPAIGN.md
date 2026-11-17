# Menu Quest campaign

Build confidence by turning familiar Rust concepts into pieces of a real menu.
The learner has read most of the Rust Book, but this is their first project path.
Keep each chat focused on one task and the learner's explanation, not on shipping
an assistant-written replacement. See [onboarding](README.md) and the
[tutor rules](../AGENTS.md).

## Six chapters

| Chapter                                                  | Intended outcome                                                                | Gate / status                                                                                   |
| -------------------------------------------------------- | ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| [01 — Launchpad](chapters/01-launchpad/)                 | Return a greeting and turn borrowed text into owned display labels.             | Starter levels `01-greeting`, `02-labels`; each needs tests, quiz and discussed review.         |
| [02 — Catalog](chapters/02-catalog/)                     | Construct typed menu actions and find an action without copying it.             | Starter levels `03-catalog`, `04-lookup`; same three gates.                                     |
| [03 — Safe actions](chapters/03-safe-actions/)           | Separate an owned command plan from a consent decision, without execution.      | Starter levels `05-command-plan`, `06-confirmation`; same three gates.                          |
| [04 — Rofi bridge](chapters/04-rofi/README.md)           | Feed the existing native mode without changing the design.                      | Future brief only; protocol tests and explicit host visual acceptance needed when implemented.  |
| [05 — Reversible state](chapters/05-state/README.md)     | Model state changes and restoration against isolated fixtures.                  | Future brief only; fixture round trips, failure cases and explain-back needed when implemented. |
| [06 — Opt-in migration](chapters/06-migration/README.md) | Evaluate a staged Rust integration while preserving compatibility and rollback. | Future brief only; explicit user opt-in, production validation and host acceptance required.    |

The six starter levels are **not** six complete integrations. Later chapters
have no stub puzzles or runner gates yet. Their acceptance goals are briefs for
future conversations, not claims of readiness or authorization to change the host.

## Starter level contracts

The task text, supplied types and checks define the exact exercise contract.
This table is a map, not an implementation or a substitute for reading the task.

| ID                | Piece to build                                                      | Idea to explain back                                                                |
| ----------------- | ------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `01-greeting`     | `greeting() -> &'static str`                                        | What is returned, and why its reference remains valid.                              |
| `02-labels`       | `action_label(&str) -> String`                                      | Borrowed input versus owned output.                                                 |
| `03-catalog`      | Construct the supplied `Action` struct.                             | How named fields express one menu action.                                           |
| `04-lookup`       | Borrowed lookup returning `Option<&Action>`.                        | Where the reference comes from and what absence means.                              |
| `05-command-plan` | A `Result` containing owned program + argv; reject a blank program. | Validation, ownership and why argument boundaries matter. Never execute the plan.   |
| `06-confirmation` | An enum with `Ready` / `NeedsConfirmation`, gated on consent.       | How the variants express a decision without performing an action. Never execute it. |

No new Rust crates are needed for the current runner. Do not turn the starter
levels into a GUI, a command executor or a rewrite of the live menu.

## What counts as clearing a starter level?

1. **Tests:** `check [ID]` establishes the checked behavior for the current source.
2. **Quiz:** `quiz [ID]` checks a related concept; wrong answers have no penalties
   or XP scores. Retry after revisiting the concept.
3. **Review:** `review [ID]` prints prompts. The learner explains their reasoning
   in chat; only then may the tutor acknowledge it with `approve ID`. Approval
   reruns tests and requires a passed quiz. Printing prompts is not approval.

All three gates are needed to clear the next level. Explicit IDs allow inspecting
and checking other levels, not bypassing the learning conversation. Source edits
invalidate stored evidence through fingerprinting. Local `.quest-progress` is a
resume aid, not a protected exam, proof of understanding or host verification.
Tests run learner code and are not a security sandbox.

There is no deadline. A small correct explanation is worth more than a fast green
check. Use [JOURNAL.md](JOURNAL.md) for genuine discussion notes and open questions;
leave it blank until there is something observed to record.

## Reference shelf

Use the official [Rust Book](https://doc.rust-lang.org/book/) for ownership,
structs, enums, error handling and tests. Use the official
[standard library reference](https://doc.rust-lang.org/std/) to look up `str`,
`String`, slices, `Option`, `Result`, filesystem and path APIs as needed. Neither
requires another full read before starting.

For compatibility, current local source is authoritative:
[menu orchestration](../menu.nu), [native mode](../rofi-mode.c),
[theme](../desktop.rasi), [GIO helper](../apps.c),
[command dispatcher](../shadow.nu) and [installation wiring](../default.nix).
The future briefs explain which parts must stay stable; campaign completion
does not automatically migrate any of them.
