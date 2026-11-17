# Chapter 01 — Launchpad

Welcome to Menu Quest. You know much of the Rust Book; now make two tiny pieces
work inside a project. The small size is intentional: first learn the edit,
check, explain loop, without also learning a GUI or application architecture.

| Level                           | Mission                                  | New piece                                            |
| ------------------------------- | ---------------------------------------- | ---------------------------------------------------- |
| [01 — Greeting](01-greeting.md) | Return the quest's first signal.         | A function's return value and a static string slice. |
| [02 — Labels](02-labels.md)     | Build display text from a borrowed name. | An owned `String` that survives its input.           |

Start with `menu-quest task 01-greeting` in the
[development shell](../../README.md). Functions are already supplied; edit only
the named exercise file. The first `todo!()` failure is expected. Neither task
needs printing, a subprocess or GUI startup; the supplied checks only inspect
returned data. Tests still execute learner code, so this is not a security sandbox.

For each level, predict before editing, check the behavior, take the quiz and
explain your reasoning in chat. `review` prints prompts, not approval. Tests,
quiz and tutor acknowledgement after discussion are all needed to clear a level.
See the [campaign](../../CAMPAIGN.md) for the full path; take just one task now.
