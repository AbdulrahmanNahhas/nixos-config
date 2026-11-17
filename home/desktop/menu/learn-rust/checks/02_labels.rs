#[path = "../chapters/01-launchpad/02_labels.rs"]
mod exercise;

#[test]
fn labels_an_application() {
    assert_eq!(exercise::action_label("Ghostty"), "Open Ghostty");
}

#[test]
fn preserves_unicode_and_whitespace() {
    assert_eq!(exercise::action_label("読書 📚"), "Open 読書 📚");
    assert_eq!(exercise::action_label("two  words"), "Open two  words");
    assert_eq!(exercise::action_label(""), "Open ");
}

#[test]
fn output_outlives_the_input() {
    let label = {
        let name = String::from("Files");
        exercise::action_label(&name)
    };
    assert_eq!(label, "Open Files");
}
