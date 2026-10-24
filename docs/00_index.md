---
updated_at: 2026-10-19
current_focus:
---

# 00 Index

## Read Policy

Read this file first. Do not scan all docs unless needed. Read the active workstream or issue, then only related specs and guides.

## Current Focus

- [ISSUE-20261001-rsvp-clipboard-quiz](issues/ISSUE-20261001-rsvp-clipboard-quiz.md) — implement the approved in-reader clipboard comprehension quiz

## Active Workstreams

<!-- own-doc-update:generated active-workstreams begin -->
- [WS-20261024-erase-data-protection](workstreams/WS-20261024-erase-data-protection.md) — 消去の前に、ここにしか無いデータを守る · high · due none
<!-- own-doc-update:generated active-workstreams end -->

## Specs

- [SPEC-rsvp-html-infographic](specs/SPEC-rsvp-html-infographic.md) — `f` で図解HTMLを開き、一時ファイルを終了時に削除する。`h/j/k/l` 操作も追加
- [SPEC-rsvp-clipboard-summary](specs/SPEC-rsvp-clipboard-summary.md) — 起動時の本文を日本語で要約し、同じReaderでRSVP再生する
- [SPEC-rsvp-clipboard-quiz](specs/SPEC-rsvp-clipboard-quiz.md) — `q` で本文理解クイズを行い、`a`・`b`・`c` で回答する

## ADRs

- [ADR-20260929-rsvp-summary-cli-prompt-file](adrs/ADR-20260929-rsvp-summary-cli-prompt-file.md) — use a local Claude-compatible CLI and an editable summary prompt file
- [ADR-20260926-large-type-rsvp-script-command](adrs/ADR-20260926-large-type-rsvp-script-command.md) — original native Swift full-screen design
- [ADR-20260927-resizable-rsvp-window-escape](adrs/ADR-20260927-resizable-rsvp-window-escape.md) — use a resizable window and app-local Escape handling
- [ADR-20260927-raycast-extension-speed-preferences](adrs/ADR-20260927-raycast-extension-speed-preferences.md) — configure WPM in Raycast settings and start the Swift reader
- [ADR-20260929-rsvp-live-keyboard-controls](adrs/ADR-20260929-rsvp-live-keyboard-controls.md) — adjust WPM and seek during reading with arrow keys
- [ADR-20260930-rsvp-launch-reader-app-bundle](adrs/ADR-20260930-rsvp-launch-reader-app-bundle.md) — launch the signed Swift reader through macOS Launch Services
- [ADR-20260930-rsvp-subscription-only-cli-environment](adrs/ADR-20260930-rsvp-subscription-only-cli-environment.md) — keep the summary CLI on subscription authentication
- [ADR-20261001-rsvp-disposable-html-diagram-hjkl](adrs/ADR-20261001-rsvp-disposable-html-diagram-hjkl.md) — open temporary diagrams in the browser and add HJKL controls

## Active Issues

<!-- own-doc-update:generated active-issues begin -->
- [ISSUE-20260927-raycast-speed-preference](issues/ISSUE-20260927-raycast-speed-preference.md) — Configure RSVP speed in Raycast settings · medium · due none
- [ISSUE-20260927-rsvp-japanese-light-chunking](issues/ISSUE-20260927-rsvp-japanese-light-chunking.md) — Japanese RSVP chunking with native NaturalLanguage rules · medium · due none
- [ISSUE-20260927-rsvp-window-escape](issues/ISSUE-20260927-rsvp-window-escape.md) — Use a resizable RSVP window with keyboard controls · high · due none
- [ISSUE-20260929-rsvp-clipboard-summary](issues/ISSUE-20260929-rsvp-clipboard-summary.md) — Implement RSVP clipboard summary · medium · due none
- [ISSUE-20261001-rsvp-clipboard-quiz](issues/ISSUE-20261001-rsvp-clipboard-quiz.md) — Implement RSVP clipboard comprehension quiz · medium · due none
- [ISSUE-20261001-rsvp-html-infographic-hjkl-shortcuts-cleanup](issues/ISSUE-20261001-rsvp-html-infographic-hjkl-shortcuts-cleanup.md) — Add disposable clipboard infographic and HJKL shortcuts · high · due none
<!-- own-doc-update:generated active-issues end -->

## Unassigned Issues

<!-- own-doc-update:generated unassigned-issues begin -->
<!-- own-doc-update:generated unassigned-issues end -->

## Guides

- [GUIDE-rsvp-clipboard](guides/GUIDE-rsvp-clipboard.md) — install and use the RSVP clipboard reader

## Archive Policy

Completed workstreams and issues are stored in their respective archive directories. Archive files are historical context, not current truth.

## Index Policy

This file stays under 32 KB and no line exceeds 500 characters (`validate_repo_docs.py` enforces both). One link and one line of routing per entry, under 200 characters after the link, with no status words (the frontmatter `status` is the only status). Current Focus holds at most five entries. Progress narrative goes to the work unit or `docs/log/`. `docs_hygiene.py --fix` moves violations out.

Rows between `own-doc-update:generated` markers are generated from front matter (`workstream`, `priority`, `due`) by `create_issue.py`, `create_workstream.py` and `docs_hygiene.py --fix`; do not edit them by hand. An issue that belongs to a workstream is routed from that workstream's Split Issues, not from Active Issues. Unassigned Issues lists issues whose declared workstream is not active.
