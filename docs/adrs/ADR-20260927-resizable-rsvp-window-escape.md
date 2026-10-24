---
id: ADR-20260927-resizable-rsvp-window-escape
status: accepted
scope: development
created_at: 2026-09-27
updated_at: 2026-09-27
source_workstreams: []
source_issues: [ISSUE-20260927-rsvp-window-escape]
related_specs: []
related_guides: [GUIDE-rsvp-clipboard]
supersedes: "ADR-20260926-large-type-rsvp-script-command"
superseded_by: ""
---

# Decision: Use a resizable window with application-level Escape handling

## Context

The first version used a borderless, full-screen panel. In use, `Esc` did not always reach the display view's `keyDown` handler, and the user prefers a regular window. A window also needs to let the user resize the reading area and close it with its title-bar button.

## Decision

Use a centered, titled, resizable `NSWindow`, sized up to 960 × 460 points within the active display. Keep the reader view as its first responder and install an app-local key-down monitor for `Esc`; the window's close button also ends the command. Do not monitor keyboard events systemwide.

## Alternatives Considered

- Keep the full-screen borderless panel: it does not match the user's preferred windowed presentation and relied on the view remaining first responder for `Esc`.
- Add a global keyboard monitor: it would receive Escape while other applications are frontmost, but the reader only needs in-app dismissal and app-local monitoring avoids systemwide keyboard access.

## Consequences

### Positive

- The reader behaves like a normal window, and the user can choose its size.
- Escape is handled before in-app responder dispatch, while the view keeps a direct key handler as a fallback.
- The close button and Escape both terminate the native reader process.

### Negative or Follow-up

- Escape is handled while the reader app receives keyboard events; it is not a systemwide hotkey.
- Text is constrained by the window dimensions and may scale or wrap as the user resizes it.

## Links

- Source issue: [ISSUE-20260927-rsvp-window-escape](../issues/ISSUE-20260927-rsvp-window-escape.md)
- Current behavior: [GUIDE-rsvp-clipboard](../guides/GUIDE-rsvp-clipboard.md)
