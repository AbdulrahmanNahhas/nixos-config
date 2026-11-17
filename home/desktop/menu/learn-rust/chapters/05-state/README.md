# Chapter 05 — Reversible state

**Future brief only.** There are no runnable levels or stub puzzles here. Scope a
small task together after the [starter work](../../CAMPAIGN.md); do not infer that
state management or production integration is ready.

## Outcome

Learn to represent a menu-related state change, save the previous value and
restore it reliably. Start with **isolated, reversible fixtures**, not the live
desktop, user files, system services or the quest's own progress database.

Use a deliberately chosen temporary fixture directory with known inputs. Keep
reading, deciding and writing separate enough to explain and test. Do not add a
background watcher, a service or production persistence wiring for this lesson.

## Boundaries for a future task

- Agree on the fixture format and the intended transition before implementation.
  State what is saved, what changes, what restoration means and how failure is
  reported; do not silently invent a live-state schema.
- Keep all test writes inside the selected fixture directory. No access to live
  Noctalia settings, wallpaper history, home configuration or production caches
  is needed to learn the concept.
- Define behavior for absent or malformed input and failed writes. Avoid claiming
  that returning an error automatically leaves the previous state intact.
- Exercise restore and repeated operations against fixtures. Inspect both the
  result and the remaining files, rather than checking only a return value.
- Keep fixture state separate from `.quest-progress`: passing a persistence test
  must not award review or alter learning gates.

The existing [layout](../../../layout.nu) and
[wallpaper](../../../wallpaper.nu) code can provide domain context when a task
needs it. Read current source rather than treating a brief as its specification;
production behavior is not to be changed as part of a fixture exercise.

## Acceptance when implemented

- Tests establish a fixture change-and-restore round trip and define repeated
  restore behavior.
- Missing/malformed fixture data and write failures are covered without damaging
  the known baseline or reaching outside the fixture directory.
- Cleanup and a reproducible fixture reset are demonstrated.
- The learner explains ownership of state, error propagation, what is reversible
  and what the tests cannot establish about the real host.

These goals are not completed gates. Running tests executes learner code and is
not a security sandbox; safe path selection and reviewing writes still matter.
Real-state adoption needs separate permission and the
[migration review](../06-migration/README.md).

## References

- [Rust Book](https://doc.rust-lang.org/book/): ownership, error handling and tests.
- [Standard library](https://doc.rust-lang.org/std/): `fs`, `path`, `io` and `Result`.
- [Campaign](../../CAMPAIGN.md); [journal template](../../JOURNAL.md).
