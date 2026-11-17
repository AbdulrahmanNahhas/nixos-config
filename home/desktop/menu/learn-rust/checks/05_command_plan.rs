#[path = "../chapters/03-safe-actions/05_command_plan.rs"]
mod exercise;
use exercise::{Action, CommandPlan, plan};

fn action(program: &'static str, args: &'static [&'static str]) -> Action {
    Action {
        id: "fixture",
        label: "Fixture only",
        program,
        args,
        confirm: false,
    }
}

#[test]
fn describes_a_command_without_running_it() {
    let plan = plan(&action(
        "not-an-installed-program",
        &["msg", "settings-open"],
    ));
    assert_eq!(
        plan,
        Ok(CommandPlan {
            program: "not-an-installed-program".into(),
            args: vec!["msg".into(), "settings-open".into()],
        })
    );
}

#[test]
fn arguments_are_data_not_shell_source() {
    let arguments = &[
        "",
        "two words",
        "a;b",
        "$(example)",
        "\"quoted\"",
        "読書 📚",
    ];
    let result = plan(&action("fixture", arguments)).expect("nonempty program is valid");
    let actual: Vec<&str> = result.args.iter().map(String::as_str).collect();
    assert_eq!(actual, arguments);
}

#[test]
fn rejects_a_blank_program() {
    for program in ["", " ", "\t\n"] {
        assert_eq!(
            plan(&action(program, &[])),
            Err("program must not be blank")
        );
    }
}

#[test]
fn preserves_nonblank_program_exactly() {
    assert_eq!(
        plan(&action("/example path/tool", &[])).unwrap().program,
        "/example path/tool"
    );
    assert_eq!(plan(&action(" tool ", &[])).unwrap().program, " tool ");
}
