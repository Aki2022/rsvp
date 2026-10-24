---
id: ADR-20260929-rsvp-live-keyboard-controls
status: accepted
scope: development
created_at: 2026-09-29
updated_at: 2026-09-29
source_workstreams: []
source_issues: [ISSUE-20260927-rsvp-window-escape]
related_specs: []
related_guides: [GUIDE-rsvp-clipboard]
supersedes: ""
superseded_by: ""
---

# Decision: Use arrow keys to adjust RSVP speed and seek

## Context

The saved Raycast WPM preference chooses the starting pace, but a reader may want to tune speed or revisit a phrase without closing the separate native window. The existing app-local keyboard monitor can receive keys while the window is active, and the reader already estimates each phrase's display interval from WPM, phrase length, and punctuation.

## Decision

Use the app-local key handler while the RSVP window is active. `Up` and `Down` change the current run's WPM by 25, bounded by the existing 30–1200 range. Apply the new interval immediately and preserve the fraction already read in the current phrase. Keep completed phrase durations fixed so increasing WPM does not move past progress backward; recalculate the current and future phrase intervals. The Raycast preference remains the starting value on the next run.

`Left` and `Right` seek backward or forward by 10 seconds on the estimated reading timeline at the current WPM. Include the existing phrase-length and punctuation timing adjustments, clamp at the beginning and end, and allow seeking while paused. The final phrase remains visible at the end. The lower-left displays current WPM; the lower-right displays the estimated reading position and total, which follows seeks and updates when WPM changes. Keep Space pause/resume and Escape dismissal unchanged.

## Alternatives Considered

- Change the stored Raycast preference on every arrow press: the requested adjustment is for the active reading session; the saved preference continues to choose the next run's starting speed.
- Seek by a fixed number of phrases: phrase lengths and punctuation pauses vary, so phrase counts do not correspond consistently to 10 seconds.

## Consequences

### Positive

- Speed can be tuned and text revisited without restarting the reader or opening settings.
- Seeking uses the same duration model as playback, so progress and navigation stay aligned.

### Negative or Follow-up

- The seek interval is an estimate based on heuristic phrase timing, not a wall-clock guarantee.
- Arrow shortcuts work only while the RSVP app is active; WPM adjustments reset to the saved preference on the next launch.

## Links

- Source issue: [ISSUE-20260927-rsvp-window-escape](../issues/ISSUE-20260927-rsvp-window-escape.md)
- Current behavior: [GUIDE-rsvp-clipboard](../guides/GUIDE-rsvp-clipboard.md)
