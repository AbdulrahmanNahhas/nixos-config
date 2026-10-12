{
"title": "Checklist conventions",
"group": "REFERENCE",
"weight": 51,
"build": {
"render": "link",
"list": "always"
}
}

The checklist is maintained in `guide/tools.json`. It groups related components into compact rows and owns the release-watch links.

- **[x]**: the row's source checks match its Nix declarations.
- **[ ]**: a source check no longer matches, or the candidate is explicitly not selected.
- **[?]**: inherited options, hardware compatibility or runtime behavior need verification.
- **Monitored**: follow development; no deployment claim.
- **★**: generated into the primary release watchlist from the same entry.

Source checks use file paths and regular expressions against comment-stripped source. They describe local declarations, not the evaluated module graph. If you move or substantially rewrite a declaration, update its source check; a missing source file fails the build. Rebuild after configuration edits.

The purpose column gives the brief technical role. Click a component to open its source preview or primary project documentation. Existing research and historical audit notes remain in the reference section.

Add a row only when it represents a major system component or a useful candidate. Put operational detail in reference Markdown and planned work in the roadmap. Runtime results and installed versions require separate measurements.
