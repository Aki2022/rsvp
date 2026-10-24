---
schema_version: 2
id: ISSUE-20260929-rsvp-clipboard-summary
status: in_progress
workstream: none
priority: medium
due: none
created_at: 2026-09-29
updated_at: 2026-09-30
branch: ""
pr: ""
related_specs: [SPEC-rsvp-clipboard-summary]
related_guides: [GUIDE-rsvp-clipboard]
guide_impact: required
guide_impact_reason: ""
---

# Implement RSVP clipboard summary

## Goal

Add an `s` shortcut that summarizes the launch-time clipboard text using the configured Claude Code-compatible command and reads the result in the existing RSVP window.

## Acceptance

- The Raycast preference selects an executable name or absolute path, defaulting to `claude2`.
- The editable prompt is created at the specified Application Support path and existing edits are preserved.
- `s` pauses the source, shows generation status, then plays a Japanese summary in the same window; Escape cancels and failure permits Space to resume the source position.
- verify: human-review — After loading the rebuilt extension in Raycast, use non-sensitive clipboard text and confirm summary generation, playback controls, cancellation, and failure recovery.
  <!-- `machine — <command and expected result>`, or `human-review — <who reviews what>` -->

## Current Status

as of 2026-09-30 — The reader is packaged as a signed app bundle and launched through Launch Services from Raycast. Clipboard text travels through a mode-`0600` one-time file in a mode-`0700` temporary directory; the text itself is not exposed in process arguments. A harmless synthetic sentence successfully passed through the app's summary CLI, produced non-empty RSVP tokens, and entered summary playback using only the configured `claude2` subscription CLI; API/provider environment variables were filtered. Unit tests, Swift type-check, app signature verification, Raycast packaging, and the synthetic app-level summary passed. The exact Raycast command and clipboard-to-file wrapper still need a normal user-facing launch check.

## Next Actions

1. Run the rebuilt RSVP Clipboard command from Raycast with a harmless copied sentence and confirm the app opens through the private file handoff.
2. Press `s` in that Raycast-launched reader; confirm summary playback. If that path differs from the successful app-level run, diagnose the Raycast launcher without using API credentials or the user's clipboard text.

<!-- First bullet = the very next command or step (or what unblocks a blocked issue). Required once work starts; the validator rejects an empty section. -->

## Guide Impact

- Decision: required
- Target or reason: `GUIDE-rsvp-clipboard` now documents the CLI preference, editable prompt path, summary controls, and remaining runtime limitation.

## Notes

- Any live request uses only the configured Claude subscription CLI and a synthetic, non-sensitive test sentence; direct API billing is prohibited.
- This workspace has no Git repository, so the implementation remains in the supplied project directory without a branch.

## Log

<!-- Append-only, dated: `- 2026-09-29 — what changed / what was learned`. The only place chronology belongs. -->

- 2026-09-29 — Implemented the shortcut, CLI handoff, cancellation, prompt copy, and RSVP summary playback. `npm run build -- --non-interactive --output /tmp/rsvp-extension-build` succeeded, including Swift compilation and the Raycast package build. Documentation validation passed with the pre-existing speed-preference warning and this issue's expected no-branch warning. No live CLI request was made; Raycast interaction review remains.
- 2026-09-29 — `npm run build` updated the registered local Raycast extension successfully. The installed Swift helper matches the workspace build, and its package contains the new preference and prompt asset.
- 2026-09-29 — User reported `要約失敗` after pressing `s`. Updated failure handling to show a privacy-safe category or CLI exit code instead of only the generic message, and clear that detail when resuming the source. The actual CLI failure remains unverified because no live summary request was run.
- 2026-09-29 — The installed `claude2 --help` output showed that `--bare` only permits API-key or `apiKeyHelper` authentication and skips OAuth/keychain reads. Replaced it with `--safe-mode`, whose help states authentication remains available while Claude customizations are disabled. Removed the redundant `mcp__*` deny pattern; `--safe-mode` and `--tools ""` provide the intended tool restrictions.
- 2026-09-29 — Rebuilt the extension successfully. The workspace and registered Raycast helper binary and Swift source match byte-for-byte; documentation validation passed with only the known missing-branch warnings. No live LLM request was made.
- 2026-09-29 — Identified the primary failure cause from the installed Claude Code CLI help: `--bare` disables OAuth and keychain credential lookup. Replaced it with `--safe-mode`, which disables customizations while preserving auth, and removed an unnecessary MCP deny pattern. Rebuilt and installed; only a live non-sensitive Raycast summary can verify the subscription CLI end to end.
- 2026-09-30 — User reported the updated reader still showed `要約コマンドを確認してください`. The Raycast settings UI confirmed `claude2` was configured. Changed it to the same executable's verified absolute path, avoiding the Raycast login-shell lookup. Split command-setting, lookup, execution-permission, and resolver errors into separate privacy-safe details. End-to-end LLM execution remains unverified.
- 2026-09-30 — Updated the resolver to use zsh's external-command lookup, preserve the login-shell `PATH`, and return distinct safe errors. `npm run build -- --non-interactive --output /tmp/rsvp-extension-build` and the registered `npm run build` succeeded; the installed reader binary and Swift source match the workspace. The exact resolver output and configured absolute executable both passed local checks. No LLM request was made.
- 2026-09-30 — The latest screenshot still shows the old generic `要約コマンドを確認してください` text. That exact text is absent from the updated source; current errors distinguish invalid settings, missing commands, execution permission, and resolver failure. Confirmed the registered helper binary and Swift source still match the workspace. This points to a reader process that has not reloaded after the rebuild; close and relaunch RSVP before retrying. End-to-end LLM execution remains unverified.
- 2026-09-30 — The next screenshot showed `CLI終了コード:1`, confirming that the configured command started. A read-only `claude2 doctor` reported no active Claude.ai subscription sign-in and a non-writable login keychain. Updated the reader to classify sign-in and keychain errors without displaying raw CLI stderr. No LLM request was made; the user must authenticate before playback can be verified.
- 2026-09-30 — User noted that `claude2` works in Terminal. Re-evaluated the prior `doctor` result: it ran in Codex's restricted environment, which emitted `mise ERROR Operation not permitted`, so its Keychain/authentication findings are not evidence about the user's normal Terminal or Raycast. Official Raycast, Node, zsh, and Claude Code documentation plus local launch code show that the extension inherits Raycast's process environment; interactive-shell variables may be absent. Replaced login advice with environment-comparison guidance. No authentication change or LLM request was made.
- 2026-09-30 — Added a failure-only diagnostic line that reports whether Claude configuration, auth/API-key, proxy, and custom TLS variables are set, without exposing their values. This makes the Raycast-side environment visible for comparison with the working Terminal. Rebuilt locally and in the registered Raycast extension; no live LLM request was made.
- 2026-09-30 — Confirmed the resolver copies the login shell's `PATH` only; it does not copy other variables from `.zprofile`, and `whence -p` resolves external commands rather than aliases/functions. Documented these additional Terminal/Raycast differences and the official Claude Code rule that `ANTHROPIC_API_KEY` overrides subscription auth in print mode. Because the Raycast env summary appears only after a failed request, it is not a no-request preflight; do not retry until the billing route is safe.
- 2026-09-30 — The user confirmed API-key billing is not to be used. The new Raycast failure screen shows `cfg=default`, `key=off`, and all displayed auth, OAuth, endpoint, proxy, and TLS flags off, while the summary CLI still exits 1. Added a preflight that refuses a non-empty `ANTHROPIC_API_KEY` and runs the configured CLI's documented `auth status --text` before sending summary input. A missing subscription login now produces a specific safe message and no summary request.
- 2026-09-30 — The workspace build and registered `npm run build` both succeeded with the authentication preflight. Confirmed the installed reader executable and Swift source match the workspace byte-for-byte. Documentation validation passed with the existing missing-branch warnings; no summary request or tests were run.
- 2026-09-30 — User clarified that only Claude subscription authentication is allowed and reported the preflight still failed. The screenshot showed the extension stopping on its separate `auth status --text` check before invoking the summary command. Removed that preflight and the UI environment-variable diagnostic; strip API keys/tokens, custom API endpoints, and Bedrock/Vertex/Foundry routing variables from the child CLI environment while preserving subscription auth and `CLAUDE_CONFIG_DIR`. Updated the spec, guide, and ADR. No summary request was made; rebuild and Raycast verification are pending.
- 2026-09-30 — Expanded subscription-only filtering to remove every `ANTHROPIC_*` environment variable, Bedrock API credentials, and the documented Bedrock/Mantle/Vertex/Foundry/Claude Platform on AWS provider switches. The official Claude Code env-var reference confirms that `ANTHROPIC_API_KEY` takes precedence over subscription auth in print mode. Registered `npm run build` succeeded; installed `rsvp.swift` and `rsvp-reader` each match the workspace. Documentation validation passed with the existing missing-branch warnings. No LLM request or tests were run; manual Raycast summary verification remains.
- 2026-09-30 — User reported the installed actual-request path still showed `CLI終了コード:1`. Ran one short synthetic CLI request from the Codex execution context with API and alternate-provider environment variables removed; it exited 1, and a read-only `auth status --text` in that same execution context returned 1. `claude2 --version` reported 2.1.285. Neither result proves the user's Terminal authentication because the execution context is not the Terminal app. Updated failure classification to inspect stdout and stderr while preserving privacy; need to rebuild and then obtain the actual Terminal's read-only auth status to compare contexts.
- 2026-09-30 — In response to the user's request to test before reporting success, confirmed there is still no successful summary: the available subscription-only synthetic request in the Codex execution context exited 1. The registered build and helper parity checks had succeeded, but they do not verify Raycast's authenticated runtime. The CUA tool denied Terminal access for safety, so the actual Terminal auth state remains unknown; next step is a one-line, read-only auth check that reveals only exit status and whether an API-key variable is set.
- 2026-09-30 — Re-ran Swift type-check and `npm run build -- --non-interactive --output /tmp/rsvp-extension-build`; both exited 0. This confirms the source compiles and Raycast can package it, not that subscription-backed summary generation succeeds in Raycast.
- 2026-09-30 — The user's latest screenshot still showed the generic subscription-auth failure. Added a failure-only diagnostic with safe categories for config default/custom, login-zsh OAuth environment presence, and Keychain state marked unverified; it never displays paths, credentials, environment variable names, or raw CLI output. Added a regression test for this diagnostic; all three environment-bridge tests and Swift type-check pass. Rebuild and live Raycast retry remain pending. No summary/API request was made.
- 2026-09-30 — `npm run build` succeeded and `npm run dev` loaded the command in Raycast; search shows `RSVP Clipboard`. The user’s current clipboard contents were not used, so no live summary or API request was made. End-to-end auth diagnosis now needs a retry with non-sensitive text.
- 2026-09-30 — The user's Terminal auth check returned `auth_exit=1` and `api_key=`. The current official CLI reference says `claude auth status` exits 0 when logged in and 1 when not. This explains why the CLI command can launch but the summary request exits 1: the subscription login is not active. Recommended the subscription login flow without `--console`; no login or summary request was initiated by the agent.
- 2026-09-30 — The user clarified that interactive login works and asked whether API login caused the failure. The CLI reference distinguishes `claude auth login` from `claude auth login --console` (the latter is API billing). Since Terminal still reports auth status 1, documented a remaining hypothesis: the shell may resolve `claude2` through an alias/function while RSVP deliberately resolves only an external executable. Requested a path-free command-type check and sanitized status text before changing the resolver or login handling.
- 2026-09-30 — The user supplied the requested output: `whence -w claude2` reports `command`, and visible auth status says `Login: Expired` / `Not logged in`. This rules out a shell alias/function mismatch and identifies expired local Claude Code credentials. The account is an organization account; official plan documentation says Team seats include Claude Code while usage-based Enterprise plans bill usage at API rates. Require subscription-seat confirmation before any summary request because the user disallows API billing.
- 2026-09-30 — The user ran `claude2 auth login` and reported `Login successful`. Agent-side read-only `claude2 auth status` still exits 1, confirming that the task execution environment does not share the user's authenticated CLI context. No summary request was made. Next verify auth status in the user's Terminal, confirm the organization billing model is subscription-included, then proceed to actual Raycast validation.
- 2026-09-30 — The user confirmed that their account uses subscription billing and Claude Code works in Terminal; only the agent's isolated execution context cannot access that login. Accepted this as authoritative, removed the unnecessary plan-verification step, and retained the strict no-API constraint. The remaining verification is the actual post-login `s` flow in Raycast.
- 2026-09-30 — The latest screenshot still showed Raycast's safe authentication error after successful Terminal login. Updated CLI resolution to capture `HOME`, `PATH`, `CLAUDE_CONFIG_DIR`, and Claude.ai OAuth variables from interactive login zsh for both command-name and absolute-path settings. Added `--restricted` to skip user/project/local settings and kept filtering all `ANTHROPIC_*` and alternate-provider variables. Added synthetic shell-bridge tests; they caught and fixed framing bugs caused by startup output and `.zlogout`. `python3 -m unittest discover -s tests -v`, Swift type-check, helper build, and registered `npm run build` passed. A temporary test preference did not appear in Raycast Settings, indicating Raycast had not reloaded the rebuilt manifest; we did not press `s` or submit a summary request. Removed the temporary input hook and rebuilt the final extension. No API request was made.
- 2026-09-30 — Replaced direct executable launch with a signed `RSVPReader.app` bundle opened via Launch Services. Clipboard input now travels through a one-time mode-`0600` file in a mode-`0700` temporary directory, and the content is removed from process arguments. Added a build script, app startup status handoff, and an ADR recording app identity as an unproven Keychain/authentication hypothesis. `python3 -m unittest discover -s tests -v` passed (4 tests), Swift type-check passed, app signature and Info.plist validated, and `npm run build -- --non-interactive --output /tmp/rsvp-extension-build-app` succeeded with the app bundle included. These checks do not prove the subscription CLI succeeds from Raycast; synthetic end-to-end authentication remains to be tested.
- 2026-09-30 — Launched the bundled reader through Launch Services with a harmless synthetic sentence and a temporary E2E-only build, then invoked the normal summary path using `claude2`. The result passed CLI status validation, produced RSVP tokens, and reached summary playback; the E2E hook was removed before the production rebuild. The actual current clipboard was untouched, and no API key/provider path was available. Final production rebuild and full test run passed. The Raycast JavaScript command's clipboard handoff remains for user-facing verification.

## Completion

- [ ] Implementation completed or intentionally not needed
- [ ] Specs updated if direction or requirements changed
- [ ] Guide impact classified before implementation
- [ ] Guides updated in the same slice if implemented behavior changed
- [ ] Branch merged and cleaned up (or intentionally kept — note why)
- [ ] 00_index.md updated
- [ ] Moved to docs/issues/archive/ when complete
