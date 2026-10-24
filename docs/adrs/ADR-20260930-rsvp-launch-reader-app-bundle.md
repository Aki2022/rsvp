---
id: ADR-20260930-rsvp-launch-reader-app-bundle
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

# Decision: Launch the RSVP reader as a signed macOS app bundle

## Context

The Raycast-hosted Swift reader can display clipboard text, but its summary CLI reports authentication failures even though the configured Claude subscription command works in Terminal. The visible failures point to the child CLI's authentication context, not failure to receive clipboard text. The user prohibits API billing and wants the local subscription CLI only.

Raycast's process context may differ from Terminal, and macOS Keychain access can depend on the requesting application's code identity. Packaging the Swift reader as an app and launching it through Launch Services is a bounded experiment to give the summary process a distinct, stable host identity. It may not change the CLI's Keychain authorization, so only an end-to-end subscription summary can confirm a benefit.

## Decision

Package the Swift AppKit reader as an ad-hoc signed `RSVPReader.app` with a stable bundle identifier. Raycast starts it through `/usr/bin/open -n -a ... --args`, keeping the user-facing Raycast command and its WPM/CLI preferences.

Raycast stores clipboard text in a one-time file under a unique mode-`0700` temporary directory. The input file is mode `0600`; only the input and status file paths are passed in the app's arguments. The Swift app deletes the input after reading it and signals startup readiness through the status file. Raycast deletes the temporary directory when the window is ready or startup fails. Clipboard text is never placed in the command line, environment, or diagnostic output.

The reader continues to invoke only the user-configured Claude Code-compatible CLI through the interactive login zsh and the existing subscription-only environment filter. Do not add a direct Anthropic API path or API credential fallback.

## Alternatives Considered

- Continue launching the Swift executable directly from Raycast: preserves the current host context, which is the context where the user reports authentication failure.
- Put clipboard text directly in app launch arguments: exposes potentially sensitive text in process arguments and creates command-line size limits.
- Use stdin for a Launch Services app: Launch Services does not provide an equivalent inherited stdin handoff, so use a short-lived private input file.
- Replace subscription authentication with a direct API: explicitly prohibited by the user.

## Consequences

### Positive

- Swift app startup is delegated to macOS Launch Services with a stable app bundle identity.
- The existing Raycast preferences and reader window remain in place.
- Clipboard handoff remains private to the user account and does not appear in argv or logs.

### Negative or Follow-up

- A synthetic, non-sensitive summary succeeded when the signed reader app was launched through Launch Services and invoked the filtered `claude2` subscription CLI. The Raycast JavaScript clipboard wrapper still needs its own live check.
- The temporary file exists briefly on disk until the app reads it; process or system failure before cleanup can leave the private temporary directory behind.
- App bundling and ad-hoc signing alone do not prove subscription authentication; only the actual CLI summary request provided that evidence. No API key or API billing path was used for the synthetic check.

## Links

- Source issue: [ISSUE-20260929-rsvp-clipboard-summary](../issues/ISSUE-20260929-rsvp-clipboard-summary.md)
- Summary behavior: [SPEC-rsvp-clipboard-summary](../specs/SPEC-rsvp-clipboard-summary.md)
- Usage guide: [GUIDE-rsvp-clipboard](../guides/GUIDE-rsvp-clipboard.md)
