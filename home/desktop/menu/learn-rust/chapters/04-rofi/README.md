# Chapter 04 — Rofi bridge

**Future brief only.** No runnable levels, stub puzzles or ready integration are
provided here. After the [starter chapters](../../CAMPAIGN.md), agree on one small
task in chat before adding exercises or implementation. The production menu
remains unchanged.

## Outcome

Let learner-written Rust supply menu rows to the **existing native C Rofi mode**,
keeping the same theme, layout, icons, search and navigation behavior. This is
not a switch to generic Rofi script mode, and it is not a new visual design.

Read the current [native mode](../../../rofi-mode.c),
[menu orchestration](../../../menu.nu) and [theme](../../../desktop.rasi) before
specifying a task. Source is authoritative if this brief ever drifts.

## Compatibility boundary

The native mode reads one row per line from stdin, with **five tab-separated
fields**, in this order:

| Field     | Encoding                              |
| --------- | ------------------------------------- |
| `kind`    | Plain text row kind.                  |
| `display` | Base64-encoded display text.          |
| `search`  | Base64-encoded search text.           |
| `label`   | Base64-encoded completion/label text. |
| `icon`    | Base64-encoded icon text.             |

Those are five fields total, not five encoded payloads after a kind. The first
field is not base64. Do not replace this with Rofi script-mode metadata or send
raw tabs/newlines inside payload fields. Keep the mode's root/category and
back-navigation behavior, including the distinction between visible navigation
and typed catalog search.

A future task should isolate row encoding from any process launch, using fixed
fixtures first. Choose the implementation approach with the learner; this brief
does not add a base64 dependency or ask for an unsolicited encoder solution.

## Acceptance when implemented

- Protocol tests cover field count/order, encoding, empty payloads, Unicode and
  text containing tabs/newlines without corrupting record boundaries.
- Fixture comparisons demonstrate compatibility with the current native mode.
- The learner explains the boundary between action data, serialized rows and
  Rofi presentation, including an error case.
- A separately agreed, non-destructive host preview verifies visuals and
  interaction against the current menu: theme, icons, navigation, search and
  cancellation. Tests alone cannot establish visual parity.

Do not wire the preview into production, install a replacement or launch real
menu actions to satisfy this chapter. Any later cutover belongs to the explicit
[opt-in migration](../06-migration/README.md), not to passing protocol tests.

## References

- [Rust Book](https://doc.rust-lang.org/book/): strings, modules and testing.
- [Standard library](https://doc.rust-lang.org/std/): byte/string and I/O APIs.
- [Campaign and gates](../../CAMPAIGN.md); [reversible-state brief](../05-state/README.md).
