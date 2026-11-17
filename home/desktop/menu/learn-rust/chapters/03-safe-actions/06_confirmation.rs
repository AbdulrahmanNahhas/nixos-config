#[path = "../../support/action.rs"]
mod model;
pub use model::Action;

#[derive(Debug, PartialEq, Eq)]
pub enum Decision {
    Ready,
    NeedsConfirmation,
}

pub fn authorize(action: &Action, consent: bool) -> Decision {
    todo!("Level 06: decide whether consent is needed; do not run the action")
}
