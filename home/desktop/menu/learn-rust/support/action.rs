// Supplied vocabulary for the starter exercises, not the final production model.
#[derive(Debug, PartialEq, Eq)]
pub struct Action {
    pub id: &'static str,
    pub label: &'static str,
    pub program: &'static str,
    pub args: &'static [&'static str],
    pub confirm: bool,
}
