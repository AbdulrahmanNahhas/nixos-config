# Shadow handbook

A local Hugo theme. No npm dependencies, remote theme, fonts or runtime server. Node is used only by the optional build checker and CI.

## Build

```sh
cd /saved/nixos-config/guide
./build.sh
# Optional preview with automatic rebuild:
./build.sh serve
```

The script uses installed Hugo, or gets Hugo from this flake's pinned Nixpkgs input. Open `index.html` or run `sys-guide`. The generated HTML pages embed their styles and scripts; keep and commit them together after rebuilding. Each sidebar section has its own page. Local builds use a temporary directory and remove it after copying the HTML pages. New previews also use a temporary directory. An older running preview may recreate ignored `public/` output and its lock file; neither belongs in Git or the deployment artifact.

## Edit one source

| Information | Authoritative source |
| --- | --- |
| Technical explanations | `docs/*.md`, including JSON front matter |
| Grouped technology checklist / source checks / watch links | `tools.json` |
| Proposed work | `roadmap.json` |
| History lanes and milestones | `timeline.json` |
| Configuration previews and Flatpak IDs | Actual `modules/` and `shadow/` files; mounted by Hugo |
| Input revisions | Actual `flake.lock`; mounted by Hugo |
| Sidebar pages and ordering | `pages/*.md` front matter |
| Presentation | `layouts/` and `assets/` |

Add a Markdown file with front matter containing `title`, `group` and optional `weight` / `sources`. It appears automatically on the technical reference page. Ordinary Markdown links between documents work across the offline handbook. Checklists render natively; personal review marks are separate browser-local state. Historical audit notes are dated evidence, not current inventory.

Only configuration files are mounted; encrypted secrets and decrypted runtime files are excluded. A build updates source snapshots, not runtime verification or manually written decisions. Review those decisions when the underlying policy changes.

Technology status checks update from local declarations on build. Inherited/runtime-dependent entries remain marked for verification. The release watchlist is generated from the same rows; do not maintain another list of names and links. See the checklist conventions in the handbook.

## Checks before committing

```sh
./guide/build.sh
node guide/check.mjs guide
git diff --check
```

The local build automatically runs the checker when Node is available. The checker verifies generated files, sidebar links, current-page markers, IDs and cross-page anchors. The same check runs in GitHub Actions. Hugo warnings fail the build. Keep all generated HTML pages together; do not edit them directly.

## GitHub Pages

The workflow at `.github/workflows/guide-pages.yml` builds from source on every push to `main` or manual dispatch. It uses Hugo 0.167.0 from its official release and verifies the archive checksum. Only the generated `guide/dist/` artifact is uploaded. It does not upload source folders, ciphertext or runtime secrets.

After committing and pushing, select **Settings → Pages → Source → GitHub Actions** in the repository. Then run **Publish Shadow handbook**, or let a push to `main` trigger it. The workflow gets the actual Pages base URL; flat relative links support both project subpaths and offline use.

Primary instructions: [Hugo deployment guide](https://gohugo.io/host-and-deploy/deploy-to-github-pages/) and [GitHub custom Pages workflows](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages). Deployment has not been performed by the local build. The configuration preview page contains the deliberately included repository configuration.

History uses one `lanes` list in `timeline.json`. Each milestone stores its label, date, explanation and commit evidence once; Hugo derives monthly headings, adaptive weekly detail, period lengths and counts. Each record has a stable ID and a track. A bar ends only when another record explicitly replaces, updates or removes it; independent additions remain open on separate tracks. No end date is maintained separately. Add a milestone to its lane without maintaining a second event or period list. Local commits do not trigger deployment; pushing to `main` rebuilds the hosted guide.

History defaults to Adaptive scale. Months with multiple changes in one lane and the current month are expanded to weekly detail; Months and Weeks controls override the scale. Period details open in a keyboard-accessible dialog so the timeline stays compact. Unknown starts remain in an Earlier column.

History relationships use `replaces`, `updates`, `removes`, `buildsOn` and `complements` IDs. Keep dates on events, not duplicated on the entries they end. Component labels are looked up from those IDs. Commit links use the single `params.repositoryURL` setting; upstream source links may be recorded separately. NixOS release history is sourced from pinned Nixpkgs versions, never inferred from `stateVersion`.

History distinguishes dependency/extension (`buildsOn`) from independent coexisting layers (`complements`). End markers distinguish replacement, update and removal, and dialogs link both start and ending evidence to GitHub. Release pins and configuration changes are repository facts; dates of installation or activation require separate evidence.
