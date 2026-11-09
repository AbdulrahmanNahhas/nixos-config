# Repository Guidelines

## Project Structure & Organization

This flake configures the single `shadow` host and Ash's Home Manager environment
(account `aqua`). `flake.nix` owns inputs and outputs. `configuration.nix`
explicitly selects system features and wires Home Manager; `home.nix` explicitly
selects user features and owns user identity and defaults.

- `system/`: machine-wide configuration, grouped into `base`, `hardware`,
  `storage`, `networking`, `security`, `desktop` and `services`.
- `home/desktop/`: Niri, Noctalia, appearance and desktop integration.
- `home/terminal/`: Fish, Ghostty, Yazi and terminal tools.
- `home/apps/`: applications, editors and development integration together.
- `home/packages.nix`: user packages without dedicated configuration.
- `home/secrets.nix`: user-facing encrypted-secret helpers.
- `encrypted-secrets/`: committed SOPS ciphertext only.

Keep detected hardware in `system/hardware/detected.nix`, disk layout in
`system/storage/disks.nix` and persistence in `system/storage/persistence.nix`.
Keep scripts, icons, styles and other assets beside their owning feature.

Use a file for a small feature and a folder for a feature with several files or
assets. Keep `default.nix` where it configures a multi-file feature; avoid category
files that only forward imports. The two root entry files are the explicit
indexes of active features. Keep disabled drafts visibly disabled there.
Do not add automatic import discovery, `modules/`, host folders or composition
layers without a concrete need. Do not import Home Manager user modules from
system feature files; Home Manager wiring belongs in `configuration.nix`.

## Build, Test, and Development Commands

- `nix flake check`: evaluate all flake outputs and catch module errors.
- `nh os build /saved/nixos-config`: build the complete system without activating it.
- `nh os build /saved/nixos-config --update`: update all flake inputs and build without activation.
- `nh os test /saved/nixos-config`: activate temporarily; the previous configuration returns after reboot.
- `nh os switch /saved/nixos-config`: build and activate a reviewed configuration.
- `nix fmt`: format every Nix file with the flake's `nixfmt`/`fd` formatter.
- `niri validate --config ~/.config/niri/config.kdl`: validate the live Niri configuration, including Noctalia's generated include.

Never run destructive Disko installation/formatting commands as a test.
Use `nh` for system builds and updates. Use `nix` only for operations without an
`nh` equivalent, such as flake checks, formatting and evaluation. Prefer existing
prebuilt packages over maintaining complex local source-build workarounds.

## Coding Style & Naming Conventions

Use two-space indentation and `nixfmt` output for Nix. Prefer small domain-focused
files with lowercase descriptive names, such as `system/services/power.nix`.
Keep hardware facts with their owning hardware or storage configuration; use
passed identity values instead of repeating host or user paths where practical.
Keep comments brief and direct: explain constraints, hardware workarounds and
security tradeoffs. Put longer explanations in the appropriate documentation.

## Testing Guidelines

There is no unit-test framework or coverage target. For configuration changes, run `nix flake check`, `git diff --check`, and `nh os build /saved/nixos-config`. For documentation-only changes, check local links and run `git diff --check`. Validate edited KDL/TOML with its owning application when possible. For boot, storage, GPU, networking, or persistence changes, use `nh os test` before `switch` and verify the relevant service or hardware state. Build validation does not authorize activation.

## Documentation Maintenance

The primary documents have distinct roles. Keep each fact in its owning document
and link between them instead of duplicating inventories or plans.

### README.md: stable project guide

Keep the README short, clear and direct. It explains this machine and repository,
the main entry files and folders, the normal validation and activation workflow,
and essential persistence, secrets and recovery guidance.

It should change infrequently. Do not put application inventories, technology
comparisons, release watchlists, task progress or validation transcripts here.
Update it when structure, operating commands or essential recovery guidance
changes. Link to configuration for exact paths and settings and to the other
documents for the inventory and planned work.

### REFERENCES.md: current system and tools inventory

Use REFERENCES as the readable inventory of the OS components, configurations,
applications and tools Ash deliberately uses or declares in this repository.
Include CLI, TUI, GUI and web applications, including custom commands where useful.
Cover deliberately selected tools rather than transitive package dependencies.

Separate two main parts, with clear functional groups inside each:

1. **OS and configuration:** the system foundation, hardware, boot and storage,
   networking, security, desktop/session components and configuration tooling.
2. **Applications and tools:** terminal tools, development tools, browsers,
   productivity, communication, media, reading, gaming and other relevant uses.

Use concise tables. Each entry should identify its name, purpose, technology or
interface, installation/management source, status and meaningful notes. Link the
name to official documentation or upstream and the configuration to its local
owner when available. Keep versions in the lock/configuration unless needed to
explain a compatibility constraint.

Make technology concrete where relevant: GPUI, Electron, GTK, Qt, TUI, CLI or web.
Distinguish the interface from the implementation framework; verify framework
claims using upstream sources and say unknown when unverified. Do not infer a
framework from appearance or package format.

Record user-stated preferences and decisions in the notes, such as keeping a
tool, trying it, looking for an alternative, or a specific limitation. Clearly
separate current tools, trials, disabled drafts and replacement candidates;
declared configuration alone does not establish current use or successful host
verification. Do not invent preferences or present a candidate as installed.

Keep learning resources and general manuals in a compact supporting section.
REFERENCES is primarily the grouped inventory, not a collection of external links.

### ROADMAP.md: major work checklist

Use a clear Markdown checklist for significant improvements, migrations and
adoption work, grouped by goal. Examples of the appropriate scale include Secure
Boot, a backup and restore strategy, a storage migration, or a major service or
tooling transition. Examples are not authorization to add new roadmap goals.

Each item should state the intended outcome and a concise completion criterion.
Add priority, dependencies or a next action only when useful and supported by the
user's decisions or repository evidence. Keep the main list focused on outstanding
work; retain completed major milestones briefly when useful.

Do not turn it into an app inventory, a release feed, a list of every package
update, a record of small tweaks or a speculative backlog. A tool belongs here
only when its adoption or replacement is a substantial planned change; link to
its REFERENCES entry for details. Check off work only when its stated completion
criteria are met. If host acceptance is required, a successful build alone does
not complete the item.

### Updating documentation

Update only the document and section that owns the changed fact. An addition,
removal or replacement of a deliberately selected tool should update its inventory
entry. Small setting changes need no documentation unless they alter a documented
purpose, status, limitation or operating instruction. Update roadmap items when
scope or completion evidence changes; keep routine tool changes out of the README
and roadmap. Do not rewrite all three documents after every edit.

Configuration is authoritative for declarations. Distinguish source declarations,
successful checks/builds, activation and host verification. Never invent adoption
dates, commit IDs, live acceptance or user preferences. Keep documents curated;
do not add task logs or validation transcripts. These documentation rules take
precedence over broader update-on-every-change wording elsewhere in the repository.

Before committing, review the staged diff, check documentation links and run
`git diff --check`. Documentation and comment changes need no activation.
Never include decrypted secrets, credentials or private runtime files in documentation.

## Commit & Pull Request Guidelines

Use `<scope>: <imperative description>` for new commit subjects, with a lowercase
scope such as `zed`, `graphics`, `power`, `network`, `system` or `docs`. For example:
`graphics: prefer AMD renderer in niri`. Describe the actual change, keep subjects
concise, and split independent work into focused commits. Preserve existing commit
IDs and history evidence when standardizing future titles; rewriting published
history is a separate task because it changes IDs and downstream links.

Pull requests should explain motivation, affected modules, validation, and rollback
concerns. Include screenshots only for visible desktop changes and link related
issues when applicable.

## Security & State

Do not commit credentials, keys, tokens, or `/saved/secrets/nix.conf`. Root is tmpfs; document persistence changes in `README.md` only when they affect existing persistence guidance or require essential migration or recovery instructions. Do not list every new application state directory there; the configuration owns the exact paths. Preserve unrelated modifications in a dirty worktree.
