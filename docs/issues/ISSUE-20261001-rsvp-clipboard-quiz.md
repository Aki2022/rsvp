---
schema_version: 2
id: ISSUE-20261001-rsvp-clipboard-quiz
status: in_progress
workstream: none
priority: medium
due: none
created_at: 2026-10-01
updated_at: 2026-10-06
branch: ""
pr: ""
related_specs: [SPEC-rsvp-clipboard-quiz]
related_guides: [GUIDE-rsvp-clipboard]
guide_impact: required
guide_impact_reason: "10問固定と不足コンテンツ時の挙動が画面操作に影響するため、実装時にガイドを更新する"
---

# Implement RSVP clipboard comprehension quiz

## Goal

Add an in-reader quiz that tests understanding of the launch-time clipboard text using the approved active spec. Reuse the configured subscription-authenticated CLI and show the quiz in the existing Swift Reader window.

## Acceptance

- verify: machine — npm test and npm run build -- --non-interactive --output /private/tmp/rsvp-clipboard-quiz-build pass; focused tests cover question decoding and count limits, key mapping, answer locking, score and reader restoration without calling a real LLM CLI
  <!-- `machine — <command and expected result>`, or `human-review — <who reviews what>` -->
- `q` starts a quiz from the original clipboard text with URLs removed while the original or summary is playing, paused, or finished, and preserves the prior reading position.
- The editable prompt is created at `~/Library/Application Support/RSVP Clipboard/quiz.md` without overwriting later user edits.
- The configured CLI generates exactly ten distinct, grounded questions; if the source cannot support ten, the Reader shows an insufficient-content state without starting a partial quiz.
- `a`, `b`, and `c` answer a question; the first answer locks, feedback remains until Space, and Space advances. The final score uses the actual question count, and Space returns to the prior reader position paused.
- Escape and window close cancel generation and close the Reader. No quiz questions or scores are persisted.
- No direct API, new dependency, authentication/configuration change, or real LLM call is used by automated tests.

## Current Status

as of 2026-10-06 — The user reports the quiz is now somewhat functional, but the complete flow is not verified. The accepted requirement is exactly ten questions; current decoding and prompt behavior still allow fewer, so the feature remains in progress.

## Next Actions

1. Enforce exactly ten grounded questions (or show insufficient content without starting a partial quiz), then run the focused tests, full test suite, and package build; follow with an in-app `q` flow to verify question text, choices, answers, feedback, score, and return to the reader.

<!-- First bullet = the very next command or step (or what unblocks a blocked issue). Required once work starts; the validator rejects an empty section. -->

## Guide Impact

- Decision: required
- Target or reason: Update `GUIDE-rsvp-clipboard.md` with quiz launch, answer, feedback, scoring, and exit controls after implementation.

## Notes

- Authorization envelope from the user's feature request and approved spec: implement this quiz in the existing Swift Reader; use only the configured subscription-authenticated CLI; do not call a direct API or add dependencies. Run local tests and report their results.
- Automated tests must use deterministic fixtures/fakes; they must not invoke a real LLM CLI or send clipboard content externally.
- The summary spec previously deferred quiz generation and scoring; this active quiz spec now owns those requirements. The infographic spec excludes quizzes from diagram generation; this feature remains a separate in-reader experience.
- Implementation is expected in `assets/RSVPKeyAction.swift` and `assets/rsvp.swift`, with a small quiz model/helper and focused tests. Update the guide in this implementation slice.
- The shared workspace has no Git metadata, so no branch can be created or merged here.
- The GUI smoke attempt used only synthetic text and a local fake CLI; the process exited before writing its ready marker. No real LLM CLI was invoked, and the temporary fixture was removed.

## Log

<!-- Append-only, dated: `- 2026-10-01 — what changed / what was learned`. The only place chronology belongs. -->

- 2026-10-01 — Implemented the quiz model, Reader interaction, editable prompt handoff, and documentation. `npm test` and the Raycast extension build pass. A synthetic direct AppKit launch exited with code 134 before readiness; its temporary input and fake CLI were removed.
- 2026-10-03 — Replaced the single giant multiline RSVP token for quiz questions and feedback with an attributed, wrapped text view inside a scroll area. Added layout coverage ensuring all three choices and the full question are laid out, and updated the user guide. `npm test`, Raycast package build, and docs validation pass; `ray develop` reports the extension ready. No real LLM call was made.
- 2026-10-04 — Confirmed the Raycast development extension remains loaded after a successful `ray develop` build. The full interactive quiz/answer GUI sequence remains unverified; no real CLI or API call was made.
- 2026-10-04 — The user’s GUI report showed an unclassified CLI exit code 1. Added diagnostics for input-size, access, auth, CLI-option, quota, and network failures, with byte counts as a safe fallback. Raw CLI output and clipboard text are never rendered. Focused tests, the full test suite, and Raycast package build pass; a new user-side `q` run is needed to surface the exact CLI cause.
- 2026-10-04 — Ran `npm run dev`; `ray develop` reported `ready` after rebuilding the signed Reader with the diagnostics helper. The next `q` run can now show a classified error or safe stream byte counts.
- 2026-10-04 — The next screenshot showed an unclassified 2.6 KB request with 56 B stdout and 172 B stderr. Added a failure-only `d` view for a 320-character sanitized stderr excerpt, held in memory and cleared on Space, Escape, or window close. No files or clipboard data are written; the updated `ray develop` reports `ready`.
- 2026-10-06 — The user reports the quiz is somewhat functional. Reconciled the active requirement with the user's earlier decision for exactly ten questions; the implementation and default prompt still permit fewer, so full completion and GUI acceptance remain open.

## Completion

- [ ] Implementation completed or intentionally not needed
- [ ] Specs updated if direction or requirements changed
- [ ] Guide impact classified before implementation
- [ ] Guides updated in the same slice if implemented behavior changed
- [ ] Branch merged and cleaned up (or intentionally kept — note why)
- [ ] 00_index.md updated
- [ ] Moved to docs/issues/archive/ when complete
