---
schema_version: 2
id: ISSUE-20260927-rsvp-window-escape
status: in_progress
workstream: none
priority: high
due: none
created_at: 2026-09-27
updated_at: 2026-09-29
branch: ISSUE-20260927-rsvp-window-escape
pr: ""
related_specs: []
related_guides: [GUIDE-rsvp-clipboard]
guide_impact: required
guide_impact_reason: ""
---

# Use a resizable RSVP window with keyboard controls

## Goal

Keep the normal resizable reader window, support pause/resume with Space, live WPM adjustment and 10-second seeking with the arrow keys, and ensure Escape or the window's close button exits the Swift reader process.

## Acceptance

- Open a centered titled window, initially up to 960 × 460 points and constrained to the active screen's visible area.
- Make the content resize with the window and allow normal mouse interaction with the title bar and resize controls.
- Close the reader on Escape using an app-local key monitor, with the view's key handler as a fallback; close the reader process when the window close button is used.
- Toggle pause and resume with Space without changing the current phrase; resuming retains the remaining display interval and pause state is visible in the window.
- Change the current session's WPM with Up / Down in 25 WPM increments, clamped to 30–1200; apply changes immediately while preserving the progress fraction through the current phrase, and show the current speed at the lower-left.
- Seek backward / forward with Left / Right by about 10 seconds on the current estimated reading timeline. Clamp to the beginning/end, support seeks while paused, and keep the final token visible at the end.
- Show reading position / estimated total time in small text at the lower-right; it freezes while paused, follows seeks, and excludes the final token's indefinite hold.
- Update the guide and record the new window behavior as the accepted design decision.
- verify: human-review — Review in Raycast that Up / Down change WPM and timing, Left / Right seek about 10 seconds and clamp at both ends, Space pause/resume preserves the current phrase and remaining interval, and Escape / close button exits.
  <!-- `machine — <command and expected result>`, or `human-review — <who reviews what>` -->

## Current Status

as of 2026-09-29 — Space pause/resume, live arrow-key speed control and estimated-time seeking, speed and progress indicators, Escape, and close-button handling are implemented in the resizable window. `npm run dev` rebuilt the Swift helper and Raycast extension successfully; the installed helper matches the workspace build and the development watcher is active. Interactive control review remains.

## Next Actions

1. Run RSVP with sample text and confirm live WPM changes, ±10-second seeking, clamping at both ends, pause/resume, the progress display, Escape, and the close button in Raycast.

<!-- First bullet = the very next command or step (or what unblocks a blocked issue). Required once work starts; the validator rejects an empty section. -->

## Guide Impact

- Decision: required
- Target or reason: `GUIDE-rsvp-clipboard` documents the window, sizing, and dismissal behavior.

## Notes

- [ADR-20260927-resizable-rsvp-window-escape](../adrs/ADR-20260927-resizable-rsvp-window-escape.md) supersedes the full-screen presentation decision.
- [ADR-20260929-rsvp-live-keyboard-controls](../adrs/ADR-20260929-rsvp-live-keyboard-controls.md) records the arrow-key speed and seek behavior.
- The supplied project folder has no Git repository, so no branch is available.

## Log

- 2026-09-27 — Replaced the full-screen panel with a centered, titled, resizable `NSWindow`; added app-local Escape handling and close-button termination; updated the guide and ADR.
- 2026-09-27 — `swiftc -module-cache-path /tmp/rsvp-swift-module-cache -typecheck rsvp.swift` exited 0. Raycast interaction was not run.
- 2026-09-28 — Added Space pause/resume with preserved remaining delay and a visible paused state; updated the guide and README. `npm run dev` rebuilt the native helper and Raycast Extension successfully; interaction review remains.
- 2026-09-28 — Added the small lower-right elapsed / estimated total time display, based on the same chunk intervals as playback; paused time and the final token hold are excluded.
- 2026-09-28 — `npm run dev` compiled the updated Swift helper and Raycast reported a successful Extension build. Runtime appearance and timing remain for manual review.
- 2026-09-29 — Added arrow-key WPM adjustment and 10-second timeline seeking, with live speed and position feedback. Manual Raycast interaction review remains.
- 2026-09-29 — `npm run build` compiled the Swift helper but the Raycast CLI could not write to its default per-user output directory under workspace permissions. `ray build --non-interactive --output <temporary-directory>` built the extension successfully; no Raycast interaction review was run.
- 2026-09-29 — Ran `npm run dev` with permission to write to Raycast's local extension directory. Raycast reported a successful build; the installed command and executable helper are present, and the helper matches the workspace build. The development watcher is active; interactive control review remains.

<!-- Append-only, dated: `- 2026-09-27 — what changed / what was learned`. The only place chronology belongs. -->

## Completion

- [ ] Implementation completed or intentionally not needed
- [ ] Specs updated if direction or requirements changed
- [ ] Guide impact classified before implementation
- [ ] Guides updated in the same slice if implemented behavior changed
- [ ] Branch merged and cleaned up (or intentionally kept — note why)
- [ ] 00_index.md updated
- [ ] Moved to docs/issues/archive/ when complete
