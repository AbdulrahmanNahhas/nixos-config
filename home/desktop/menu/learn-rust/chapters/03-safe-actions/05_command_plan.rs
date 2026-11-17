#[path = "../../support/action.rs"]
mod model;
pub use model::Action;

#[derive(Debug, PartialEq, Eq)]
pub struct CommandPlan {
    pub program: String,
    pub args: Vec<String>,
}

pub fn plan(action: &Action) -> Result<CommandPlan, &'static str> {
    todo!("Level 05: validate and describe a command; do not execute anything")
}
