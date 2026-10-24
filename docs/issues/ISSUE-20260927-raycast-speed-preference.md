---
schema_version: 2
id: ISSUE-20260927-raycast-speed-preference
status: active
workstream: none
priority: medium
due: none
created_at: 2026-09-27
updated_at: 2026-09-27
branch: ""
pr: ""
related_specs: []
related_guides: [GUIDE-rsvp-clipboard]
guide_impact: required
guide_impact_reason: ""
---

# Configure RSVP speed in Raycast settings

## Goal

Allow users to save RSVP reading speed in Raycast Settings while preserving the separate native reading window.

## Acceptance

- The Raycast command has a saved WPM setting with a 300 default and accepts only integer values from 30 to 1200.
- Each run reads the current text clipboard and passes it with the selected speed to the Swift reader.
- The resizable AppKit window, Japanese chunking rules, Escape handling, and close-button behavior remain available.
- README and guide explain local Extension setup and the preference location.
- verify: human-review — Review the Raycast setting, change WPM, run the reader, and confirm the visible pace changes while Esc and the close button still work.
  <!-- `machine — <command and expected result>`, or `human-review — <who reviews what>` -->

## Current Status

as of 2026-09-27 — With the user's explicit approval, dependencies were installed. The user confirmed that RSVP opened, but startup took about 15 seconds. The helper is now compiled during `npm run dev` / `npm run build`, and the updated Extension build succeeded with an executable for this Apple Silicon Mac. Each reading session now launches the native executable directly; the startup improvement, playback speed, Escape, and close-button behavior still need a manual run review. npm reported that the installed `@raycast/api` package requires Node >=22.22.2 while the shell uses Node 20.19.0; the Raycast build still succeeded.

## Next Actions

1. Run the command with non-sensitive sample text and review launch time, visible pace, Escape, and close-button behavior.

<!-- First bullet = the very next command or step (or what unblocks a blocked issue). Required once work starts; the validator rejects an empty section. -->

## Guide Impact

- Decision: required
- Target or reason: `GUIDE-rsvp-clipboard` documents installation, the setting, and the native reader behavior.

## Notes

- [ADR-20260927-raycast-extension-speed-preferences](../adrs/ADR-20260927-raycast-extension-speed-preferences.md) records the architecture and dependency decision.
- The supplied project folder has no Git repository, so no branch is available.

## Log

- 2026-09-27 — Replaced the standalone Script Command with an Extension preference and bundled Swift reader; Raycast interaction review is pending.
- 2026-09-27 — Automatic review rejected `npm install` because it did not treat the earlier “ok” as explicit approval for npm registry access and lockfile changes; no workaround was attempted.
- 2026-09-27 — After the user explicitly approved `npm install --cache /tmp/rsvp-npm-cache --no-audit --no-fund --ignore-scripts`, installation completed successfully. `npm run dev` compiled the Extension, and Raycast Settings visibly listed the command and its default WPM preference. Playback review remains pending.
- 2026-09-27 — User reported that RSVP opened but took about 15 seconds. Changed the launch path to a native executable compiled by npm's `predev` and `prebuild` hooks, so Swift compilation no longer occurs for every reading session. The updated Raycast build and startup time still need review.
- 2026-09-27 — `npm run dev` rebuilt the native helper and Raycast compiled the updated Extension successfully. The helper is an executable arm64 Mach-O; startup latency still awaits a manual run review.

## Completion

- [ ] Implementation completed or intentionally not needed
- [ ] Specs updated if direction or requirements changed
- [ ] Guide impact classified before implementation
- [ ] Guides updated in the same slice if implemented behavior changed
- [ ] Branch merged and cleaned up (or intentionally kept — note why)
- [ ] 00_index.md updated
- [ ] Moved to docs/issues/archive/ when complete
