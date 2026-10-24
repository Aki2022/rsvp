---
id: ADR-20260929-rsvp-summary-cli-prompt-file
status: accepted
scope: spec
created_at: 2026-09-29
updated_at: 2026-09-29
source_workstreams: []
source_issues: [ISSUE-20260929-rsvp-clipboard-summary]
related_specs: [SPEC-rsvp-clipboard-summary]
related_guides: [GUIDE-rsvp-clipboard]
supersedes: ""
superseded_by: ""
---

# Decision: Use a local CLI and an editable prompt file for RSVP summaries

## Context

The reader already receives a clipboard snapshot and displays it in a native window. The user wants `s` to summarize that text using the locally available `claude2` subscription command, then read the result in the same RSVP window. The prompt should be easy to edit without changing Raycast settings or rebuilding the extension. Future map and quiz features may use the same source text and CLI boundary.

## Decision

Use a Raycast preference for the name or absolute path of a Claude Code-compatible executable, initially `claude2`. Treat the preference as an executable identifier, not a shell command. Resolve names using a login shell, then invoke the executable directly with `--print`; send the prompt and URL-filtered source through standard input and consume plain-text standard output. Disable built-in and MCP tools and session persistence for the request. Remove API credentials, alternate API endpoints, and cloud-provider switches from the child process environment so the feature stays on subscription authentication. Do not call a metered API directly from the extension.

Store the summary prompt as an editable Markdown file in the user's application-support directory, outside the extension bundle. Create its default content during initial setup, preserve edits, and read it when `s` is pressed. The current behavior and prompt requirements are defined by [SPEC-rsvp-clipboard-summary](../specs/SPEC-rsvp-clipboard-summary.md).

## Alternatives Considered

- Call an LLM API directly: this introduces separate authentication and billing from the subscription CLI chosen for this feature.
- Keep the prompt in extension source or bundled assets: editing would require a rebuild or risk losing changes on extension updates.
- Put the entire prompt in a Raycast preference: this is cumbersome for editing multi-line text and makes the file harder to use with a normal editor.
- Accept an arbitrary shell command line in the preference: shell interpretation adds quoting and injection risks to a setting that only needs to identify an executable.

## Consequences

### Positive

- The summary uses the user's selected local CLI and the prompt can be edited without rebuilding the extension.
- The original clipboard snapshot remains available for later map and quiz features.
- Keeping the command, prompt, and input separate avoids placing clipboard text in process arguments.

### Negative or Follow-up

- The selected CLI must be installed and authenticated, and its name must resolve when launched from Raycast's GUI environment. The CLI performs normal authentication as part of the summary request; a separate `auth status` preflight is omitted because it can fail independently from the CLI request path.
- The first release accepts Claude Code-compatible command behavior. Other CLI protocols need an adapter when requested.
- The CLI request uses standard input and `--output-format text`, `--tools ""`, `--safe-mode`, and `--no-session-persistence`. `--safe-mode` is used instead of `--bare` so Claude Code customizations are disabled without disabling OAuth and keychain authentication. Subscription-only environment handling and omission of a separate auth preflight are recorded in [ADR-20260930-rsvp-subscription-only-cli-environment](ADR-20260930-rsvp-subscription-only-cli-environment.md). The command’s actual subscription response still requires a manual end-to-end Raycast check; a build and CLI help output do not prove that path works.

## Links

- Source intent: [SPEC-rsvp-clipboard-summary](../specs/SPEC-rsvp-clipboard-summary.md)
- Existing Raycast-to-Swift boundary: [ADR-20260927-raycast-extension-speed-preferences](ADR-20260927-raycast-extension-speed-preferences.md)
