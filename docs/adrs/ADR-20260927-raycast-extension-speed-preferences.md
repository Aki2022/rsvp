---
id: ADR-20260927-raycast-extension-speed-preferences
status: accepted
scope: development
created_at: 2026-09-27
updated_at: 2026-09-27
source_workstreams: []
source_issues: [ISSUE-20260927-raycast-speed-preference]
related_specs: []
related_guides: [GUIDE-rsvp-clipboard]
supersedes: "ADR-20260926-large-type-rsvp-script-command"
superseded_by: ""
---

# Decision: Use Raycast Extension preferences to configure native RSVP reading speed

## Context

The current Script Command format has no persisted per-command preference for reading speed. The user wants to change speed from Raycast Settings while keeping the reader in its own resizable window, rather than showing it inside Raycast's constrained command window.

## Decision

Replace the Script Command entry point with a local macOS Raycast Extension. Add a command-specific text preference for WPM with a default of 300; accept integers from 30 through 1200 and reject invalid values when the command runs. The command reads the current text clipboard through Raycast, writes it to a private one-time file, and opens the bundled Swift app with the selected WPM and file path. npm compiles and signs the app bundle before development and production builds. Keep the existing AppKit window, Escape handling, NaturalLanguage chunking, and punctuation pauses. The current app-bundle launch and private-file handoff are detailed in [ADR-20260930-rsvp-launch-reader-app-bundle](ADR-20260930-rsvp-launch-reader-app-bundle.md).

This supersedes the original Script Command and script-constant decisions. The resizable-window presentation remains governed by [ADR-20260927-resizable-rsvp-window-escape](ADR-20260927-resizable-rsvp-window-escape.md).

## Alternatives Considered

- Keep editing the Swift constant: it does not put the setting in Raycast Settings.
- Add a Script Command argument: it asks for a value at launch instead of reusing a saved preference.
- Render the reader in the Raycast extension view: the user asked for a separate resizable window, and the command view has the original clipping limitation.

## Consequences

### Positive

- Reading speed is saved in Raycast's command preferences and applies on the next launch.
- The native window and existing Japanese chunking remain in Swift without adding a parser dependency.

### Negative or Follow-up

- The project now depends on `@raycast/api` and requires `npm install` plus `npm run dev` for local development.
- The extension and Swift reader remain macOS-only; Swift must be available on the machine.
- Raycast's text preference stores a string, so the command validates its integer range at runtime.

## Links

- Source issue: [ISSUE-20260927-raycast-speed-preference](../issues/ISSUE-20260927-raycast-speed-preference.md)
- Current behavior: [GUIDE-rsvp-clipboard](../guides/GUIDE-rsvp-clipboard.md)
- [Raycast Manifest preferences](https://developers.raycast.com/information/manifest)
- [Raycast Preferences API](https://developers.raycast.com/api-reference/preferences)
