#[path = "../chapters/01-launchpad/01_greeting.rs"]
mod exercise;

#[test]
fn sends_the_first_signal() {
    assert_eq!(exercise::greeting(), "Shadow apprentice");
}

#[test]
fn returns_text_without_a_trailing_newline() {
    let text: &'static str = exercise::greeting();
    assert!(
        !text.ends_with('\n'),
        "Printing and returning text are different jobs"
    );
}
