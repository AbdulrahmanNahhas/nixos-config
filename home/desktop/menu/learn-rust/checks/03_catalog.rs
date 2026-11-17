#[path = "../chapters/02-catalog/03_catalog.rs"]
mod exercise;
use exercise::Action;

#[test]
fn terminal_is_a_typed_action() {
    assert_eq!(
        exercise::terminal_action(),
        Action {
            id: "terminal",
            label: "Terminal",
            program: "ghostty",
            args: &[],
            confirm: false,
        }
    );
}

#[test]
fn settings_preserves_argument_boundaries() {
    assert_eq!(
        exercise::settings_action(),
        Action {
            id: "settings",
            label: "Settings",
            program: "noctalia",
            args: &["msg", "settings-open"],
            confirm: false,
        }
    );
}
