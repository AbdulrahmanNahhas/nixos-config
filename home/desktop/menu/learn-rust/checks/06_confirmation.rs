#[path = "../chapters/03-safe-actions/06_confirmation.rs"]
mod exercise;
use exercise::{Action, Decision, authorize};

fn action(confirm: bool) -> Action {
    Action {
        id: "fixture-only",
        label: "Never run",
        program: "never-executed",
        args: &[],
        confirm,
    }
}

#[test]
fn harmless_action_needs_no_consent() {
    assert_eq!(authorize(&action(false), false), Decision::Ready);
    assert_eq!(authorize(&action(false), true), Decision::Ready);
}

#[test]
fn protected_action_waits_for_consent() {
    assert_eq!(authorize(&action(true), false), Decision::NeedsConfirmation);
    assert_eq!(authorize(&action(true), true), Decision::Ready);
}

#[test]
fn approval_is_not_mutated_into_the_catalog() {
    let protected = action(true);
    let _decision = authorize(&protected, true);
    assert!(protected.confirm);
    assert_eq!(authorize(&protected, false), Decision::NeedsConfirmation);
}
