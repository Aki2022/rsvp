---
schema_version: 2
id: ISSUE-20260926-rsvp-clipboard-overlay
status: archived
workstream: none
priority: medium
due: none
created_at: 2026-09-26
updated_at: 2026-09-26
branch: ISSUE-20260926-rsvp-clipboard-overlay
pr: ""
related_specs: []
related_guides: [GUIDE-rsvp-clipboard]
guide_impact: required
guide_impact_reason: ""
---

# Build a large-type RSVP clipboard command

## Goal

Create a Raycast Script Command that reads the latest plain-text clipboard contents in a large full-screen RSVP overlay, remains open on the final token until Escape, and lets the user change WPM in the script file.

## Acceptance

- The command reads text from the clipboard at launch and displays it token by token in a full-screen native overlay.
- The overlay keeps the final token visible until Escape closes it.
- The WPM is editable as a constant near the top of the script.
- verify: machine — swiftc -module-cache-path /tmp/rsvp-swift-module-cache -typecheck rsvp.swift exits 0
  <!-- `machine — <command and expected result>`, or `human-review — <who reviews what>` -->

## Current Status

as of 2026-09-26 — the Swift Script Command and usage guide are implemented; Swift type-checking passes. The overlay was not launched interactively in Raycast.

<!-- Snapshot for the next session, overwritten each time: first line `as of 2026-09-26 — <state in one sentence>`. History goes to ## Log, not here. -->

## Next Actions

1. No agent action remains; this issue is archived.

<!-- First bullet = the very next command or step (or what unblocks a blocked issue). Required once work starts; the validator rejects an empty section. -->

## Guide Impact

- Decision: required
- Target or reason: `docs/guides/GUIDE-rsvp-clipboard.md` records current setup and behavior.

## Notes

- [ADR-20260926-large-type-rsvp-script-command](../../adrs/ADR-20260926-large-type-rsvp-script-command.md) records why this uses a Swift Script Command and native AppKit overlay.
- No git repository was present in the supplied project folder, so no branch was created.

## Log

- 2026-09-26 — Implemented and type-checked the Swift Script Command; the interactive Raycast overlay was not launched.

<!-- Append-only, dated: `- 2026-09-26 — what changed / what was learned`. The only place chronology belongs. -->

## Completion

- [x] Implementation completed or intentionally not needed
- [x] Specs updated if direction or requirements changed
- [x] Guide impact classified before implementation
- [x] Guides updated in the same slice if implemented behavior changed
- [x] Branch kept — no Git repository was supplied
- [x] 00_index.md updated
- [x] Moved to docs/issues/archive/ when complete
