mod levels;

use levels::{LEVELS, Level};
use std::collections::BTreeMap;
use std::error::Error;
use std::fs;
use std::io::{self, Write};
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

type QuestResult<T> = Result<T, Box<dyn Error>>;

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
struct Record {
    fingerprint: u64,
    tests: bool,
    quiz: bool,
    review: bool,
}

impl Record {
    fn cleared(self) -> bool {
        self.tests && self.quiz && self.review
    }
}

#[derive(Default)]
struct Progress(BTreeMap<String, Record>);

impl Progress {
    fn parse(text: &str) -> QuestResult<Self> {
        let mut lines = text.lines();
        if lines.next() != Some("menu-quest-v1") {
            return Err(
                "Unrecognized progress format; keep the file and ask your tutor for help.".into(),
            );
        }
        let mut progress = Self::default();
        for line in lines {
            let fields: Vec<_> = line.split('\t').collect();
            if fields.len() != 5 || !LEVELS.iter().any(|level| level.id == fields[0]) {
                return Err("Malformed progress record; no progress was overwritten.".into());
            }
            let flag = |value| match value {
                "0" => Ok(false),
                "1" => Ok(true),
                _ => Err("Malformed progress flag"),
            };
            let record = Record {
                fingerprint: u64::from_str_radix(fields[1], 16)?,
                tests: flag(fields[2])?,
                quiz: flag(fields[3])?,
                review: flag(fields[4])?,
            };
            if record.review && !(record.tests && record.quiz) {
                return Err(
                    "Review record lacks its prerequisites; no progress was overwritten.".into(),
                );
            }
            if progress.0.insert(fields[0].to_owned(), record).is_some() {
                return Err("Duplicate progress record; no progress was overwritten.".into());
            }
        }
        Ok(progress)
    }

    fn encode(&self) -> String {
        let mut text = String::from("menu-quest-v1\n");
        for (id, record) in &self.0 {
            text.push_str(&format!(
                "{id}\t{:016x}\t{}\t{}\t{}\n",
                record.fingerprint,
                u8::from(record.tests),
                u8::from(record.quiz),
                u8::from(record.review)
            ));
        }
        text
    }

    fn current(&self, id: &str, fingerprint: u64) -> Record {
        self.0
            .get(id)
            .copied()
            .filter(|record| record.fingerprint == fingerprint)
            .unwrap_or(Record {
                fingerprint,
                ..Record::default()
            })
    }
}

struct Quest {
    root: PathBuf,
    progress_path: PathBuf,
}

impl Quest {
    fn load(&self) -> QuestResult<Progress> {
        match fs::read_to_string(&self.progress_path) {
            Ok(text) => Progress::parse(&text),
            Err(error) if error.kind() == io::ErrorKind::NotFound => Ok(Progress::default()),
            Err(error) => Err(error.into()),
        }
    }

    fn lock(&self) -> QuestResult<fs::File> {
        if let Some(parent) = self.progress_path.parent() {
            fs::create_dir_all(parent)?;
        }
        let file = fs::OpenOptions::new()
            .read(true)
            .write(true)
            .create(true)
            .truncate(false)
            .open(self.progress_path.with_extension("lock"))?;
        file.try_lock().map_err(|error| {
            format!("Another quest update is running, or locking failed: {error}. Retry after it finishes.")
        })?;
        // The OS releases this advisory lock on exit, including interrupted sessions.
        Ok(file)
    }

    fn save(&self, progress: &Progress) -> QuestResult<()> {
        if let Some(parent) = self.progress_path.parent() {
            fs::create_dir_all(parent)?;
        }
        let temporary = self.progress_path.with_extension("tmp");
        fs::write(&temporary, progress.encode())?;
        fs::rename(temporary, &self.progress_path)?;
        Ok(())
    }

    fn fingerprint(&self, level: &Level) -> QuestResult<u64> {
        // Deterministic evidence invalidation, not a cryptographic or anti-cheat check.
        let mut hash = 0xcbf29ce484222325_u64;
        let mut add = |bytes: &[u8]| {
            for byte in (bytes.len() as u64).to_le_bytes().iter().chain(bytes) {
                hash ^= u64::from(*byte);
                hash = hash.wrapping_mul(0x100000001b3);
            }
        };
        for relative in [level.source, level.check] {
            add(relative.as_bytes());
            add(&fs::read(self.root.join(relative))?);
        }
        if level.uses_model {
            add(&fs::read(self.root.join("support/action.rs"))?);
        }
        add(level.task.as_bytes());
        for question in level.review {
            add(question.as_bytes());
        }
        add(level.question.as_bytes());
        for choice in level.choices {
            add(choice.as_bytes());
        }
        add(&(level.answer as u64).to_le_bytes());
        Ok(hash)
    }

    fn record(&self, progress: &Progress, level: &Level) -> QuestResult<Record> {
        Ok(progress.current(level.id, self.fingerprint(level)?))
    }

    fn next(&self) -> QuestResult<Option<&'static Level>> {
        let progress = self.load()?;
        for level in LEVELS {
            if !self.record(&progress, level)?.cleared() {
                return Ok(Some(level));
            }
        }
        Ok(None)
    }

    fn select(&self, id: Option<&str>) -> QuestResult<&'static Level> {
        if let Some(id) = id {
            LEVELS
                .iter()
                .find(|level| level.id == id)
                .ok_or_else(|| format!("Unknown level {id:?}. Use list for exact IDs.").into())
        } else {
            self.next()?.ok_or_else(|| {
                "All starter levels are cleared. Discuss chapter 04 with your tutor.".into()
            })
        }
    }

    fn status(&self) -> QuestResult<()> {
        let progress = self.load()?;
        let mut cleared = 0;
        let mut chapter = "";
        println!("MENU QUEST — build your own desktop controller\n");
        for level in LEVELS {
            if chapter != level.chapter {
                chapter = level.chapter;
                println!("{chapter}");
            }
            let record = self.record(&progress, level)?;
            cleared += usize::from(record.cleared());
            let mark = |passed| if passed { "+" } else { "-" };
            println!(
                "  {:<17} tests [{}] quiz [{}] review [{}]  {}",
                level.id,
                mark(record.tests),
                mark(record.quiz),
                mark(record.review),
                level.title
            );
        }
        println!(
            "\n{cleared}/{} starter badges earned. [+] recorded for current source; [-] pending.",
            LEVELS.len()
        );
        println!("Chapters 04–06 are future briefs, not implemented levels or host acceptance.");
        Ok(())
    }

    fn task(&self, level: &Level) -> QuestResult<()> {
        println!(
            "\n{} — {}\nChapter {}",
            level.id, level.title, level.chapter
        );
        println!("Edit: {}\n", self.root.join(level.source).display());
        println!("{}", level.task);
        let record = self.record(&self.load()?, level)?;
        println!(
            "Next gate: {}",
            if !record.tests {
                "predict, edit, then check"
            } else if !record.quiz {
                "quiz"
            } else if !record.review {
                "review: explain your code in chat"
            } else {
                "cleared — use next to continue"
            }
        );
        Ok(())
    }

    fn check(&self, level: &Level) -> QuestResult<bool> {
        let _lock = self.lock()?;
        self.check_locked(level)
    }

    fn check_locked(&self, level: &Level) -> QuestResult<bool> {
        let fingerprint = self.fingerprint(level)?;
        let mut progress = self.load()?;
        let previous = progress.current(level.id, fingerprint);
        let mut record = Record {
            tests: false,
            review: false,
            ..previous
        };
        progress.0.insert(level.id.to_owned(), record);
        self.save(&progress)?;

        let directory = self.root.join("target/quest-checks");
        fs::create_dir_all(&directory)?;
        let executable = directory.join(format!("{}-{}", level.id, std::process::id()));
        println!(
            "Checking {} only. TODO failures are expected until you solve it.",
            level.id
        );
        io::stdout().flush()?;
        let compiler = std::env::var_os("RUSTC").unwrap_or_else(|| "rustc".into());
        let compiled = Command::new(compiler)
            .arg("--edition=2024")
            .arg("--test")
            .arg("--crate-name")
            .arg(level.id.replace('-', "_"))
            .arg(self.root.join(level.check))
            .arg("-o")
            .arg(&executable)
            .status()
            .map_err(|error| {
                format!(
                    "Could not start rustc: {error}. Enter the documented Nix development shell."
                )
            })?;
        let passed = compiled.success()
            && Command::new(executable)
                .arg("--test-threads=1")
                .status()?
                .success();
        if self.fingerprint(level)? != fingerprint {
            return Err(
                "Files changed during the check. Run it again against the current source.".into(),
            );
        }
        progress = self.load()?;
        record = progress.current(level.id, fingerprint);
        record.tests = passed;
        record.review = passed && previous.review && record.quiz;
        progress.0.insert(level.id.to_owned(), record);
        self.save(&progress)?;
        if passed {
            println!("Tests passed. Understanding is a separate gate: quiz, then review.");
        } else {
            println!("Not yet. Read the first useful diagnostic; try hint or bring it to chat.");
        }
        Ok(passed)
    }

    fn quiz(&self, level: &Level, answer: Option<&str>) -> QuestResult<()> {
        println!("\n{} — concept checkpoint\n{}", level.id, level.question);
        for (index, choice) in level.choices.iter().enumerate() {
            println!("  {}. {choice}", char::from(b'A' + index as u8));
        }
        let input = if let Some(answer) = answer {
            answer.to_owned()
        } else {
            read_line("Choice [A/B/C], or Enter to leave: ")?.unwrap_or_default()
        };
        if input.trim().is_empty() {
            println!("Quiz left unchanged. Return whenever you're ready.");
            return Ok(());
        }
        let choice = choice_index(&input).ok_or("Choose exactly A, B or C.")?;
        if choice != level.answer {
            return Err(format!(
                "Not quite. {} No progress lost; try again when ready.",
                level.feedback
            )
            .into());
        }
        let _lock = self.lock()?;
        let mut progress = self.load()?;
        let mut record = self.record(&progress, level)?;
        record.quiz = true;
        progress.0.insert(level.id.to_owned(), record);
        self.save(&progress)?;
        println!("Concept checkpoint passed. Now explain the idea using your own code in review.");
        Ok(())
    }

    fn review(&self, level: &Level) {
        println!(
            "\nExplain-back for {}. Answer in chat, not in the progress file.",
            level.id
        );
        for question in level.review {
            println!("  • {question}");
        }
        println!("Your tutor may ask for a small variation. No approval has been recorded.");
    }

    fn approve(&self, level: &Level) -> QuestResult<()> {
        let _lock = self.lock()?;
        if !self.record(&self.load()?, level)?.quiz {
            return Err("Pass this level's quiz first. Approval also requires an actual explain-back discussion.".into());
        }
        if !self.check_locked(level)? {
            return Err("Review cannot be acknowledged while tests fail.".into());
        }
        let mut progress = self.load()?;
        let mut record = self.record(&progress, level)?;
        if !(record.tests && record.quiz) {
            return Err("Evidence changed. Repeat the tests and quiz for current source.".into());
        }
        record.review = true;
        progress.0.insert(level.id.to_owned(), record);
        self.save(&progress)?;
        println!("Badge earned: {}!", level.badge);
        println!(
            "Recorded the tutor's review acknowledgement. This is trust-based, not host verification."
        );
        Ok(())
    }

    fn dispatch(&self, words: &[&str]) -> QuestResult<()> {
        let command = words.first().copied().unwrap_or("next");
        let args = words.get(1..).unwrap_or_default();
        match command {
            "help" | "--help" | "-h" if args.is_empty() => help(),
            "list" | "status" if args.is_empty() => self.status()?,
            "next" if args.is_empty() => {
                if let Some(level) = self.next()? {
                    self.task(level)?;
                } else {
                    println!(
                        "All six starter badges earned! Bring chapter 04's brief to your tutor."
                    );
                    println!("The live menu has not been migrated or changed.");
                }
            }
            "task" if args.len() <= 1 => self.task(self.select(args.first().copied())?)?,
            "check" if args.len() <= 1 => {
                if !self.check(self.select(args.first().copied())?)? {
                    return Err("Level still in progress.".into());
                }
            }
            "quiz" if args.len() <= 2 => {
                self.quiz(self.select(args.first().copied())?, args.get(1).copied())?
            }
            "review" if args.len() <= 1 => self.review(self.select(args.first().copied())?),
            "approve" if args.len() == 1 => self.approve(self.select(Some(args[0]))?)?,
            "hint" if args.len() <= 2 => {
                let (id, number) = match args {
                    [] => (None, "1"),
                    [number @ ("1" | "2" | "3")] => (None, *number),
                    [id] => (Some(*id), "1"),
                    [id, number] => (Some(*id), *number),
                    _ => unreachable!(),
                };
                let index = match number {
                    "1" => 0,
                    "2" => 1,
                    "3" => 2,
                    _ => return Err("Hint must be 1, 2 or 3.".into()),
                };
                let level = self.select(id)?;
                println!("{} — hint {number}/3\n{}", level.id, level.hints[index]);
            }
            _ => {
                return Err(
                    "Unknown command or extra arguments. Use help; level IDs appear in list."
                        .into(),
                );
            }
        }
        Ok(())
    }

    fn play(&self) -> QuestResult<()> {
        println!("MENU QUEST\nPredict → build → test → quiz → explain → earn a badge.");
        println!("Commands: task, check, quiz, hint [1/2/3], review, list, next, help, quit.");
        self.dispatch(&["next"])?;
        while let Some(line) = read_line("\nquest> ")? {
            let words: Vec<_> = line.split_whitespace().collect();
            if words.is_empty() {
                continue;
            }
            if words == ["quit"] || words == ["exit"] {
                break;
            }
            if let Err(error) = self.dispatch(&words) {
                eprintln!("{error}");
            }
        }
        println!("Session closed. Your recorded progress will be here next time.");
        Ok(())
    }
}

fn choice_index(input: &str) -> Option<usize> {
    match input.trim().to_ascii_uppercase().as_str() {
        "A" => Some(0),
        "B" => Some(1),
        "C" => Some(2),
        _ => None,
    }
}

fn read_line(prompt: &str) -> io::Result<Option<String>> {
    print!("{prompt}");
    io::stdout().flush()?;
    let mut line = String::new();
    if io::stdin().read_line(&mut line)? == 0 {
        Ok(None)
    } else {
        Ok(Some(line))
    }
}

fn help() {
    println!("Menu Quest — one level at a time, no production changes.");
    println!("  play                  interactive session (quit or Ctrl+C to leave)");
    println!("  next                  current mission (also the default command)");
    println!("  list | status         current-source tests / quiz / review evidence");
    println!("  task [ID]             mission and edit target");
    println!("  check [ID]            compile and run only this exercise's tests");
    println!("  quiz [ID]             conceptual multiple-choice checkpoint");
    println!("  quiz ID A             submit a choice without prompting");
    println!("  hint [ID] [1|2|3]     optional progressive hints; no penalties");
    println!("  review [ID]           explain-back questions, not approval");
    println!("  approve ID            tutor acknowledgement AFTER discussion; reruns tests");
    println!("Tests execute your code; this is not a security sandbox. See README.md.");
}

fn main() -> ExitCode {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).to_owned();
    let progress_path = std::env::var_os("MENU_QUEST_PROGRESS")
        .map(PathBuf::from)
        .unwrap_or_else(|| root.join(".quest-progress"));
    let quest = Quest {
        root,
        progress_path,
    };
    let args: Vec<_> = std::env::args().skip(1).collect();
    let words: Vec<_> = args.iter().map(String::as_str).collect();
    let result = if words == ["play"] {
        quest.play()
    } else {
        quest.dispatch(&words)
    };
    match result {
        Ok(()) => ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("menu-quest: {error}");
            ExitCode::FAILURE
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::time::{SystemTime, UNIX_EPOCH};

    struct Scratch(PathBuf);

    impl Scratch {
        fn new() -> Self {
            let suffix = SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .unwrap()
                .as_nanos();
            let directory =
                std::env::temp_dir().join(format!("menu-quest-{}-{suffix}", std::process::id()));
            fs::create_dir_all(&directory).unwrap();
            Self(directory)
        }
    }

    impl Drop for Scratch {
        fn drop(&mut self) {
            let _ = fs::remove_dir_all(&self.0);
        }
    }

    fn fixture(root: &Path) -> Quest {
        for level in LEVELS {
            for relative in [level.source, level.check] {
                let path = root.join(relative);
                fs::create_dir_all(path.parent().unwrap()).unwrap();
                fs::write(
                    path,
                    "// synthetic runner fixture, not an exercise solution\n",
                )
                .unwrap();
            }
        }
        fs::create_dir_all(root.join("support")).unwrap();
        fs::write(root.join("support/action.rs"), "// fixture model\n").unwrap();
        Quest {
            root: root.to_owned(),
            progress_path: root.join(".quest-progress"),
        }
    }

    #[test]
    fn progress_round_trips_and_requires_all_three_gates() {
        let mut progress = Progress::default();
        let record = Record {
            fingerprint: 42,
            tests: true,
            quiz: true,
            review: false,
        };
        assert!(!record.cleared());
        progress.0.insert(LEVELS[0].id.into(), record);
        assert_eq!(Progress::parse(&progress.encode()).unwrap().0, progress.0);
        assert!(
            Record {
                review: true,
                ..record
            }
            .cleared()
        );
    }

    #[test]
    fn corrupt_progress_is_rejected_not_silently_reset() {
        for text in [
            "",
            "menu-quest-v2\n",
            "menu-quest-v1\nunknown\t1\t1\t1\t1\n",
            "menu-quest-v1\n01-greeting\t1\t0\t0\t1\n",
            "menu-quest-v1\n01-greeting\t1\t1\tX\t0\n",
            "menu-quest-v1\n01-greeting\t1\t1\t0\t0\n01-greeting\t1\t1\t0\t0\n",
        ] {
            assert!(Progress::parse(text).is_err(), "accepted {text:?}");
        }
    }

    #[test]
    fn stale_evidence_does_not_clear_a_level() {
        let scratch = Scratch::new();
        let quest = fixture(&scratch.0);
        let level = &LEVELS[0];
        let fingerprint = quest.fingerprint(level).unwrap();
        let mut progress = Progress::default();
        progress.0.insert(
            level.id.into(),
            Record {
                fingerprint,
                tests: true,
                quiz: true,
                review: true,
            },
        );
        quest.save(&progress).unwrap();
        assert_eq!(quest.next().unwrap().unwrap().id, LEVELS[1].id);
        fs::write(quest.root.join(level.source), "// changed\n").unwrap();
        assert_eq!(quest.next().unwrap().unwrap().id, level.id);
        assert!(
            !quest
                .record(&quest.load().unwrap(), level)
                .unwrap()
                .cleared()
        );
    }

    #[test]
    fn checks_and_shared_model_are_part_of_evidence() {
        let scratch = Scratch::new();
        let quest = fixture(&scratch.0);
        let first = quest.fingerprint(&LEVELS[0]).unwrap();
        let catalog = quest.fingerprint(&LEVELS[2]).unwrap();
        fs::write(quest.root.join("support/action.rs"), "// changed model\n").unwrap();
        assert_eq!(first, quest.fingerprint(&LEVELS[0]).unwrap());
        assert_ne!(catalog, quest.fingerprint(&LEVELS[2]).unwrap());
        fs::write(quest.root.join(LEVELS[0].check), "// changed checks\n").unwrap();
        assert_ne!(first, quest.fingerprint(&LEVELS[0]).unwrap());
    }

    #[test]
    fn quiz_and_approval_have_separate_gates() {
        let scratch = Scratch::new();
        let quest = fixture(&scratch.0);
        assert!(quest.approve(&LEVELS[0]).is_err());
        assert!(quest.quiz(&LEVELS[0], Some("A")).is_err());
        assert!(!quest.progress_path.exists());
        quest.quiz(&LEVELS[0], Some("B")).unwrap();
        let record = quest.record(&quest.load().unwrap(), &LEVELS[0]).unwrap();
        assert!(record.quiz);
        assert!(!record.tests && !record.review);
        quest.review(&LEVELS[0]);
        assert!(
            !quest
                .record(&quest.load().unwrap(), &LEVELS[0])
                .unwrap()
                .review
        );
    }

    #[test]
    fn check_and_approve_work_on_synthetic_tests_only() {
        let scratch = Scratch::new();
        let quest = fixture(&scratch.0);
        let level = &LEVELS[0];
        fs::write(
            quest.root.join(level.check),
            "#[test] fn synthetic_check() { assert_eq!(2 + 2, 4); }\n",
        )
        .unwrap();
        assert!(quest.check(level).unwrap());
        assert!(
            !quest
                .record(&quest.load().unwrap(), level)
                .unwrap()
                .cleared()
        );
        quest.quiz(level, Some("B")).unwrap();
        quest.approve(level).unwrap();
        assert!(
            quest
                .record(&quest.load().unwrap(), level)
                .unwrap()
                .cleared()
        );
        assert!(quest.check(level).unwrap());
        assert!(quest.record(&quest.load().unwrap(), level).unwrap().review);
        fs::write(
            quest.root.join(level.check),
            "#[test] fn synthetic_failure() { assert!(false); }\n",
        )
        .unwrap();
        assert!(!quest.check(level).unwrap());
        assert!(!quest.record(&quest.load().unwrap(), level).unwrap().tests);
        fs::write(quest.root.join(level.check), "not valid Rust\n").unwrap();
        assert!(!quest.check(level).unwrap());
    }

    #[test]
    fn mutating_commands_cannot_overlap() {
        let scratch = Scratch::new();
        let quest = fixture(&scratch.0);
        let lock = quest.lock().unwrap();
        assert!(quest.lock().is_err());
        assert!(quest.check(&LEVELS[0]).is_err());
        assert!(quest.quiz(&LEVELS[0], Some("B")).is_err());
        assert!(quest.approve(&LEVELS[0]).is_err());
        drop(lock);
        assert!(quest.lock().is_ok());
    }

    #[test]
    fn changed_task_and_review_require_fresh_evidence() {
        let scratch = Scratch::new();
        let quest = fixture(&scratch.0);
        let fingerprint = quest.fingerprint(&LEVELS[0]).unwrap();
        let task = Level {
            task: "A changed task contract",
            ..LEVELS[0]
        };
        let review = Level {
            review: ["A changed review question", "Another question"],
            ..LEVELS[0]
        };
        assert_ne!(fingerprint, quest.fingerprint(&task).unwrap());
        assert_ne!(fingerprint, quest.fingerprint(&review).unwrap());
    }

    #[test]
    fn command_errors_and_choices_are_predictable() {
        let scratch = Scratch::new();
        let quest = fixture(&scratch.0);
        assert!(quest.select(Some("not-a-level")).is_err());
        assert!(quest.dispatch(&["check", "01-greeting", "extra"]).is_err());
        assert!(quest.dispatch(&["hint", "01-greeting", "0"]).is_err());
        assert!(quest.dispatch(&["approve"]).is_err());
        assert_eq!(choice_index(" b \n"), Some(1));
        assert_eq!(choice_index("AB"), None);
        assert_eq!(choice_index("D"), None);
    }

    #[test]
    fn every_level_has_real_files_and_bounded_metadata() {
        let quest = Quest {
            root: env!("CARGO_MANIFEST_DIR").into(),
            progress_path: PathBuf::new(),
        };
        let mut ids = std::collections::HashSet::new();
        for level in LEVELS {
            assert!(ids.insert(level.id));
            assert!(level.answer < level.choices.len());
            assert!(!level.task.trim().is_empty());
            quest.fingerprint(level).unwrap();
        }
    }
}
