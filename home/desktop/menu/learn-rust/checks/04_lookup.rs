#[path = "../chapters/02-catalog/04_lookup.rs"]
mod exercise;
use exercise::{Action, find_action};

fn action(id: &'static str, label: &'static str) -> Action {
    Action {
        id,
        label,
        program: "never-executed",
        args: &[],
        confirm: false,
    }
}

#[test]
fn finds_by_stable_id_not_label() {
    let actions = [
        action("terminal", "Shell"),
        action("settings", "Preferences"),
    ];
    assert_eq!(find_action(&actions, "settings"), Some(&actions[1]));
    assert_eq!(find_action(&actions, "Preferences"), None);
}

#[test]
fn missing_and_empty_catalog_are_normal_absence() {
    assert_eq!(find_action(&[], "terminal"), None);
    assert_eq!(
        find_action(&[action("terminal", "Terminal")], "unknown"),
        None
    );
}

#[test]
fn borrows_the_first_match_without_copying() {
    let actions = [action("same", "First"), action("same", "Second")];
    let found = find_action(&actions, "same").expect("the first action exists");
    assert!(std::ptr::eq(found, &actions[0]));
}

#[test]
fn id_does_not_need_to_live_as_long_as_the_result() {
    let actions = [action("terminal", "Terminal")];
    let found = {
        let id = String::from("terminal");
        find_action(&actions, &id)
    };
    assert_eq!(found, Some(&actions[0]));
}
