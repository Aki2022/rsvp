---
schema_version: 2
id: ISSUE-20261001-rsvp-html-infographic-hjkl-shortcuts-cleanup
status: in_progress
workstream: none
priority: high
due: none
created_at: 2026-10-01
updated_at: 2026-10-01
branch: ""
pr: ""
related_specs: [SPEC-rsvp-html-infographic]
related_guides: [GUIDE-rsvp-clipboard]
guide_impact: required
guide_impact_reason: ""
---

# Add disposable clipboard infographic and HJKL shortcuts

## Goal

Add `f` to generate a static diagram from the launch-time clipboard with the configured subscription CLI, open the temporary HTML in the default browser, and remove RSVP-owned temporary data on normal close or the next start after a crash. Add HJKL aliases for the existing seek and speed controls.

## Acceptance

- `f` pauses RSVP at the current phrase, generates HTML through the existing Claude Code-compatible subscription CLI, opens the default browser, and leaves RSVP running.
- Escape or closing RSVP cancels active generation and removes that session's complete HTML directory; the next launch removes crash leftovers without touching active sessions.
- `h` / `l` seek backward / forward by 10 seconds; `k` / `j` adjust WPM up / down by 25. This uses `j` for the final speed-down action because `l` is already assigned to forward seek and the requested keys mirror the arrow directions.
- No API key or direct metered API route is used. HTML is static, self-contained, and blocks scripts and external requests.
- verify: machine — `npm test` and `npm run build -- --non-interactive --output /private/tmp/rsvp-extension-build` pass; GUI smoke test — synthetic input + fake local CLI opens the diagram and Esc removes the session.
  <!-- `machine — <command and expected result>`, or `human-review — <who reviews what>` -->

## Current Status

as of 2026-10-01 — Implementation, `npm test`, the Raycast extension build, JavaScript syntax checks, and repository-doc validation pass. The project and Raycast extension bundles contain matching reader binaries and diagram prompt assets.

A synthetic GUI smoke test could not launch the app from this tool process: Launch Services returned `kLSNoExecutableErr` despite the executable and ad-hoc signature being present. No CLI or API was invoked by that attempt. A user-facing `f` → browser → `Esc` check is outstanding.

The duplicate `l` binding is interpreted as `j` for speed down. This workspace has no Git metadata, so there is no branch to merge.

## Next Actions

1. Re-run a synthetic `f` → browser → `Esc` smoke test from Raycast's GUI context, then verify the generated session is removed; the sandboxed command launcher could not complete this check.

<!-- First bullet = the very next command or step (or what unblocks a blocked issue). Required once work starts; the validator rejects an empty section. -->

## Guide Impact

- Decision: required
- Target or reason: implemented in `GUIDE-rsvp-clipboard`: `f`, browser handoff, temporary-file cleanup, stale-session recovery, and the HJKL aliases.

## Notes

- The user prohibits direct API calls and approved the existing subscription-authenticated `claude2` CLI path.
- The default browser can remain open after the local HTML file is deleted; the temporary file's lifecycle is owned by RSVP, not the browser cache.

## Log

<!-- Append-only, dated: `- 2026-10-01 — what changed / what was learned`. The only place chronology belongs. -->

- 2026-10-01 — Created this issue from the approved infographic draft. The user added `h` / `l` / `k` / `l`; because `l` was duplicated and the mappings mirror arrows, the last key is interpreted as `j` (down).
- 2026-10-01 — Added the native diagram action, bounded static HTML validation, per-session cleanup and stale-session recovery, editable prompt handoff, and arrow-equivalent HJKL mappings. `npm test` and the Raycast build pass; a GUI launch smoke test was attempted with synthetic text and a fake CLI but Launch Services returned `kLSNoExecutableErr` from the tool process.
- 2026-10-01 — Final `npm test` passed (5 Python tests and the Swift key/HTML/temp-store harness); the Raycast extension build completed and docs validation examined all 5 open work units. Removed the temporary build output and synthetic test fixture.

## Completion

- [x] Implementation completed or intentionally not needed
- [x] Specs updated if direction or requirements changed
- [x] Guide impact classified before implementation
- [x] Guides updated in the same slice if implemented behavior changed
- [x] Branch merged and cleaned up (or intentionally kept — no Git metadata exists in the shared workspace)
- [x] 00_index.md updated
- [ ] Moved to docs/issues/archive/ when complete (waiting for the GUI smoke test)
