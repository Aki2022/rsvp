---
id: ADR-20260926-large-type-rsvp-script-command
status: superseded
scope: development
created_at: 2026-09-26
updated_at: 2026-09-27
source_workstreams: []
source_issues: [ISSUE-20260926-rsvp-clipboard-overlay]
related_specs: []
related_guides: [GUIDE-rsvp-clipboard]
supersedes: ""
superseded_by: "ADR-20260927-raycast-extension-speed-preferences"
---

# Decision: Use a Swift Script Command for the large-type overlay

## Context

The requested reader needs to display long clipboard text in a large, unclipped presentation and remain visible until the user presses `Esc`. A view rendered inside the normal Raycast command window is constrained by that window's dimensions. The project folder is empty, and the user did not ask to publish the command to the Store.

## Decision

Implement the command as a macOS Raycast Script Command written in Swift. Use AppKit to show an independent full-screen overlay and NaturalLanguage to split text into reading tokens. Keep WPM as an editable constant in the script and avoid third-party packages.

## Alternatives Considered

- Standard Raycast extension view: keeps the reader inside the Raycast window, which preserves the original clipping constraint.
- A separate packaged macOS application: provides a native window but adds a second installable artifact and packaging workflow for a command that can run as a Swift Script Command.

## Consequences

### Positive

- The word display spans the active screen and can scale or wrap long tokens.
- The command can keep the final token visible until `Esc`.
- No npm or Swift package dependencies are required.

### Negative or Follow-up

- This is a locally imported Script Command rather than a Store-publishable Raycast extension package.
- The implementation is macOS-only and must be added as a Script Directory in Raycast settings.
- WPM changes require editing the script and relaunching the command.

## Links

- Source issue: [ISSUE-20260926-rsvp-clipboard-overlay](../issues/archive/ISSUE-20260926-rsvp-clipboard-overlay.md)
- Current behavior: [GUIDE-rsvp-clipboard](../guides/GUIDE-rsvp-clipboard.md)
