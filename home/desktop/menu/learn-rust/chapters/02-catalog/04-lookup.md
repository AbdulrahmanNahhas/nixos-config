# 04 — Find it without taking it

A menu selection needs a stable way to find its action. Search a catalog and let
the caller borrow the matching entry, rather than manufacturing a copy.

**Edit, relative to the learning root (`learn-rust/`):**
[`chapters/02-catalog/04_lookup.rs`](04_lookup.rs).
Keep the supplied signature:
`find_action<'a>(actions: &'a [Action], id: &str) -> Option<&'a Action>`.
The [Action type](../../support/action.rs) is already provided.

## Contract

- Compare the requested `id` with action IDs, not display labels; matching is exact.
- Return `Some` containing a reference to the **first** matching entry in the
  supplied slice. Do not clone, rebuild or move an action out of the catalog.
- Return `None` for an unknown ID or an empty catalog; absence is not a panic.
- The returned borrow comes from `actions`, not from the search text. The caller
  must be able to drop a temporary search `String` and still use the result while
  the catalog remains alive.

For an entry with ID `"settings"` and label `"Preferences"`, searching for
`"settings"` finds it; searching for `"Preferences"` does not. If two entries have
ID `"same"`, return the first entry itself, not just an equal value.

**Predict before editing:** Which input must outlive the returned reference?
What should a duplicate ID or empty slice do?

## Check, then explain

```sh
menu-quest check 04-lookup
menu-quest quiz 04-lookup
menu-quest review 04-lookup
```

Explain the lifetime relationship and one absence/duplicate case in chat.
`review` prints prompts; tutor acknowledgement follows discussion, not just tests.

References: [The Rust Book — References and Borrowing](https://doc.rust-lang.org/book/ch04-02-references-and-borrowing.html)
and [Validating References with Lifetimes](https://doc.rust-lang.org/book/ch10-03-lifetime-syntax.html).
