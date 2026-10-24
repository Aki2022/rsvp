---
schema_version: 2
id: WS-20261024-erase-data-protection
status: active
priority: high
due: none
created_at: 2026-10-24
updated_at: 2026-10-24
branch: ""
pr: ""
human_boundary_confirmed_at: 2026-10-24
next_human_gate: erase-day-final-gate
related_specs: []
related_guides: []
---

# 消去の前に、ここにしか無いデータを守る

## Goal

Mac の消去（reinstall の gate D）の前に、git にも backup にも無いデータを、所有者の決定（2026-10-24）どおりに守る。backup は code フォルダ を 1 ファイルも含まず、repo は GitHub からの clone だけで戻る。だから、ignore・未追跡のファイル、stash、remote に無い commit、worktree の未 commit の変更は、消去で消える。

## Success Criteria

## Authorization Envelope

- Approved scope: Mac の消去（reinstall の gate D）の前に、git にも backup にも無いデータを所有者の決定どおりに commit・移動する
- Autonomous actions allowed: 決定どおりの commit・push（PR）、code フォルダの外への移動、.gitignore の例外の追加、push 済みで要らない worktree の取り外し
- Confirm first: 決定に無いファイルの削除・公開、history の書き換え、まだ決まっていない項目の扱い
- Merge policy: CD (default) — a PR whose recorded quality gates are green merges autonomously
- Cost or usage ceiling:
- Out of scope:

## Human Gates

- Start gate: confirmed on 2026-10-24
- Next gate: erase-day-final-gate
  <!-- a named human checkpoint, or `none-workstream-complete` when nothing gates completion -->
- Stop conditions:

## Issue Queue

| Issue               | Status  | Depends on | Outcome            |
| ------------------- | ------- | ---------- | ------------------ |
| ISSUE-01-protect-unrecoverable-local-data | pending | none       | protect unrecoverable local data |

### ISSUE-01-protect-unrecoverable-local-data

- status: pending
- depends_on: []
- runnability: ready
  <!-- `ready`, or `gated on <the human decision / missing input>` — executors treat a missing value as gated and stop -->
- guide_impact: none
- related_guides: []
- guide_impact_reason: "データの置き場の整理で、挙動は変わらない"

#### Goal

**守る（git に入れるか、code フォルダの外へ移す）**
- `docs/00_index.md`・`docs/adrs/`・`docs/issues/`・`docs/log/`・`docs/specs/`・`docs/workstreams/`：`.gitignore` の「Local planning notes」の行を外して commit・push する（repo は public。agent が 2026-10-24 に走査し、ホームのパス・メール・鍵は 0 件、gitleaks も 0 件）

ただし、公開しない issue が 1 件ある。その file は repo の外（`Documents/code-preserved/rsvp/docs/issues/`）へ移し、`.gitignore` にその path を足して誤って add されないようにする。push の前にもう一度 gitleaks を流す。

#### Acceptance

- verify: machine — reinstall の repo（main）で `python3 scripts/check_code_data.py` を流し、出力に `rsvp:` で始まる行が無い
  <!-- `machine — <command and expected result>`, or `human-review — <who reviews what>` -->

#### Current Status

as of 2026-10-24 — 「Local planning notes」の ignore を外し、docs 一式を commit した（公開しない 1 件は repo の外へ移し、ignore を足した）。まだ決まっていない項目は無い。検証（reinstall の check_code_data.py に `rsvp:` の行が無いこと）は消去の前の最終 gate で確かめる。

#### Next Actions

1. Goal の「守る」と「worktree・branch」を片付ける。
2. 「まだ決まっていない」を所有者と決める。
3. reinstall の repo（main）で `python3 scripts/check_code_data.py` を流し、出力に `rsvp:` で始まる行が無いことを確かめる。

## Log

- 2026-10-24 — `.gitignore` の「Local planning notes」の行を外し、`docs/00_index.md`・`docs/adrs/`・`docs/issues/`・`docs/log/`・`docs/specs/`・`docs/workstreams/` を commit した。
- 2026-10-24 — 公開しない issue 1 件を `Documents/code-preserved/rsvp/docs/issues/` へ移し、`.gitignore` にその path を足した。`docs/00_index.md` からその行を外した。
- 2026-10-24 — push の前に gitleaks と、ホームのパス・メール・所有者の名前の grep を docs に流し、0 件だった。
- 未決: なし。

## Split Issues

Issue files in docs/issues/ that declare `workstream: <this id>`. Generated from their front matter
(create_issue.py, docs_hygiene.py --fix); do not edit between the markers.

<!-- own-doc-update:generated split-issues begin -->
<!-- own-doc-update:generated split-issues end -->

## Decisions

Record only decisions that are difficult to reverse or surprising without context.

## Completion

- [ ] Every issue meets its acceptance criteria
- [ ] Every issue records guide impact as required or none
- [ ] Required guides describe current implemented behavior
- [ ] Specs reflect any changed direction or requirements
- [ ] Next human gate reached or the workstream intentionally stopped
- [ ] 00_index.md updated
- [ ] Workstream archived when complete
