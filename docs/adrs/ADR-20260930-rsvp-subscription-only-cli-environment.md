---
id: ADR-20260930-rsvp-subscription-only-cli-environment
status: accepted
scope: development
created_at: 2026-09-30
updated_at: 2026-09-30
source_workstreams: []
source_issues: [ISSUE-20260929-rsvp-clipboard-summary]
related_specs: [SPEC-rsvp-clipboard-summary]
related_guides: [GUIDE-rsvp-clipboard]
supersedes: ""
superseded_by: ""
---

# Decision: Keep the summary CLI on subscription authentication

## Context

The user wants summaries through the locally authenticated `claude2` subscription command and does not want metered API billing. A separate `auth status --text` preflight reported that Raycast could not confirm authentication and stopped before the configured summary command ran, despite `claude2` working in Terminal. That preflight was not the user's actual summary path and did not prove the summary request would fail.

## Decision

Remove the separate authentication preflight and let the configured CLI perform its normal authentication as part of the summary request. Resolve the executable and capture `HOME`, `PATH`, `CLAUDE_CONFIG_DIR`, and Claude.ai OAuth variables from interactive login zsh, so Raycast can use the same shell-configured subscription context as Terminal. Transfer only these allowlisted values through an internal NUL-delimited pipe; never display them. Remove all `ANTHROPIC_*` variables, Bedrock/Vertex/Foundry/Claude Platform on AWS provider switches, and Bedrock API credentials from the resolver and CLI environments. Invoke Claude Code with `--safe-mode` and `--restricted`, which disables customizations and skips user, project, and local settings that could inject an API key helper or provider route. Organization-managed Claude Code policy remains in force. On an authentication failure only, show whether configuration is default or custom, whether access/refresh OAuth values were present by category, and that Keychain status is unverified. Never show environment variable names, paths, raw stderr, or credential values.

## Alternatives Considered

- Keep the `auth status` preflight: it can disagree with the actual request path and prevent a working subscription CLI from running.
- Pass the complete Raycast environment: an inherited API key or alternate provider switch could change the CLI's billing route.
- Capture only the login shell's `PATH`: this misses a custom Claude config directory or OAuth credentials set in the interactive shell startup files.
- Call an API directly: this creates a separate metered authentication and billing path that the user does not want.

## Consequences

### Positive

- The configured CLI handles authentication through the same command path used for the summary.
- API credentials and alternate provider routing inherited from Raycast or interactive shell startup are not available to the summary child process; user, project, and local settings are also skipped.
- The interactive login shell's startup files run when a summary starts; their extra stdout is isolated from the summary result.
- Error feedback comes from the actual summary CLI attempt and remains privacy-safe.

### Negative or Follow-up

- The end-to-end subscription summary still requires a manual Raycast run; a build alone does not prove authentication or summary generation succeeds.
- Organization-managed CLI policy still applies and is outside the extension's control. The extension does not inspect or change that policy.

## Links

- Source issue: [ISSUE-20260929-rsvp-clipboard-summary](../issues/ISSUE-20260929-rsvp-clipboard-summary.md)
- Current policy: [SPEC-rsvp-clipboard-summary](../specs/SPEC-rsvp-clipboard-summary.md)
- Current behavior: [GUIDE-rsvp-clipboard](../guides/GUIDE-rsvp-clipboard.md)
