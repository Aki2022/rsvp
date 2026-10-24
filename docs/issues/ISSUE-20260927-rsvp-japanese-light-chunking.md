---
schema_version: 2
id: ISSUE-20260927-rsvp-japanese-light-chunking
status: active
workstream: none
priority: medium
due: none
created_at: 2026-09-27
updated_at: 2026-09-28
branch: ISSUE-20260927-rsvp-japanese-light-chunking
pr: ""
related_specs: []
related_guides: [GUIDE-rsvp-clipboard]
guide_impact: required
guide_impact_reason: ""
---

# Japanese RSVP chunking with native NaturalLanguage rules

## Goal

Add dependency-free Japanese RSVP phrase grouping to the Swift reader, keeping the current NaturalLanguage tokenizer and non-Japanese behavior.

## Acceptance

- Detect Japanese clipboard text with `NLLanguageRecognizer` and use `NLTagger` lexical classes for grouping.
- Attach particles and common auxiliary forms to the previous chunk, group consecutive nouns up to the configured soft limit, and keep punctuation at the end of the previous chunk.
- Remove detected HTTP/HTTPS, `www.`, and bare-domain URLs before language detection and tokenization.
- If URL removal leaves no text, show a clear prompt to copy body text.
- Preserve the existing final maximum-token split and non-Japanese tokenization behavior.
- Update the user guide with the new grouping behavior and limitations.
- verify: human-review — The user reviews representative Japanese chunks in Raycast and confirms the grouping is usable.
  <!-- `machine — <command and expected result>`, or `human-review — <who reviews what>` -->

## Current Status

as of 2026-09-28 — Native Japanese phrase grouping and pre-tokenization URL removal are implemented, with a clear message when no body text remains. `npm run build:reader` succeeded with its module cache redirected to `/tmp`; the Raycast Extension build also succeeded. Playback review remains.

## Next Actions

1. Launch RSVP Clipboard with Japanese text containing scheme-based, `www.`, and bare-domain URLs; confirm the links are skipped while surrounding punctuation and text remain, and URL-only clipboard content shows the helpful prompt.

<!-- First bullet = the very next command or step (or what unblocks a blocked issue). Required once work starts; the validator rejects an empty section. -->

## Guide Impact

- Decision: required
- Target or reason: `GUIDE-rsvp-clipboard` documents the URL filter, Japanese grouping, and its limitations.

## Notes

- The Japanese parser itself continues to use Apple's NaturalLanguage framework without a parser package. The Raycast API dependency for saved settings is recorded in [ADR-20260927-raycast-extension-speed-preferences](../adrs/ADR-20260927-raycast-extension-speed-preferences.md).
- The supplied project folder has no Git repository, so no branch is available.

## Log

- 2026-09-27 — Added Japanese-only grouping for particles, common auxiliary forms, connected verbs, and bounded noun compounds; updated the guide. Raycast review remains pending.
- 2026-09-27 — `swiftc -module-cache-path /tmp/rsvp-swift-module-cache -typecheck rsvp.swift` exited 0. No automated tests were run.
- 2026-09-28 — Added regex URL removal for HTTP/HTTPS, `www.`, and bare domains before language detection and tokenization; added a clear prompt for URL-only clipboard content and updated the guide. Build and Raycast review remain pending.
- 2026-09-28 — Rebuilt the native helper and Raycast Extension successfully with `npm run dev`; playback behavior remains for manual review.
- 2026-09-28 — The standalone helper build initially could not write Swift's default module cache. Redirected it to `/tmp/rsvp-reader-module-cache`; `npm run build:reader` then exited 0.

<!-- Append-only, dated: `- 2026-09-27 — what changed / what was learned`. The only place chronology belongs. -->

## Completion

- [ ] Implementation completed or intentionally not needed
- [ ] Specs updated if direction or requirements changed
- [ ] Guide impact classified before implementation
- [ ] Guides updated in the same slice if implemented behavior changed
- [ ] Branch merged and cleaned up (or intentionally kept — note why)
- [ ] 00_index.md updated
- [ ] Moved to docs/issues/archive/ when complete
