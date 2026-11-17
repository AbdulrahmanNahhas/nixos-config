#[path = "../../support/action.rs"]
mod model;
pub use model::Action;

pub fn find_action<'a>(actions: &'a [Action], id: &str) -> Option<&'a Action> {
    todo!("Level 04: borrow the first matching action, or return absence")
}
