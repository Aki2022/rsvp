---
id: ADR-20261001-rsvp-disposable-html-diagram-hjkl
status: accepted
scope: development
created_at: 2026-10-01
updated_at: 2026-10-01
source_workstreams: []
source_issues: [ISSUE-20261001-rsvp-html-infographic-hjkl-shortcuts-cleanup]
related_specs: [SPEC-rsvp-html-infographic]
related_guides: [GUIDE-rsvp-clipboard]
supersedes: ""
superseded_by: ""
---

# Decision: Use disposable RSVP diagrams and HJKL aliases

## Context

The RSVP reader already uses a subscription-authenticated Claude Code-compatible CLI for summaries. Readers need a visual overview of the captured clipboard without switching to a metered API, and generated files must not accumulate after use. The existing native window also has arrow-key controls that should remain available alongside keyboard-only navigation.

## Decision

Pressing `f` pauses the current RSVP phrase and sends the URL-filtered launch-time clipboard text to the configured local CLI with an editable prompt. The existing restricted, subscription-only command runner is reused; no direct API path or API key is added. Bound captured CLI output to 1.5 MB, validate the result as a self-contained HTML document, reject scripts and hyperlinks, add a restrictive Content Security Policy, save it with private permissions in an RSVP-owned temporary session directory, and open it through macOS Launch Services in the default browser. RSVP stays open and paused. `Space` resumes after returning to the RSVP window.

Escape or closing the RSVP window cancels in-flight generation and removes its temporary session immediately. If the app exits abnormally, the next RSVP launch removes unlocked stale sessions while leaving sessions held by another live reader alone. Parent-directory file locking serializes startup cleanup and final removal; the empty RSVP temporary root is removed after its last session closes. No permanent diagram folder or resident cleaner is used. The external browser owns its displayed tab and cache, while RSVP owns and deletes the local HTML file.

Keep the existing arrow controls and add Vim-style aliases: `h` / `l` seek backward / forward by about 10 seconds, while `k` / `j` increase / decrease WPM by 25. The user's duplicate `l` request for forward seek and speed down is resolved as `j` for speed down, matching the requested cursor-key mapping.

## Alternatives Considered

- Store generated HTML in the repository or Application Support: it would persist after the RSVP session and collect unused diagrams.
- Embed a browser view in RSVP: the approved default-browser workflow keeps browser navigation and closing behavior familiar.
- Use a direct model API: the user requires subscription CLI authentication and prohibits metered API access.
- Map both forward seek and speed down to `l`: a single key cannot trigger both actions; Vim-style directional aliases keep the four controls distinct.

## Consequences

### Positive

- Diagram generation uses the CLI authentication path that already works for summaries and does not add a metered API.
- App-owned HTML has a short lifecycle, private permissions, crash recovery, and no app-created persistent artifact.
- The arrows and HJKL keys work as paired controls.

### Negative or Follow-up

- The external browser may keep an already-rendered page visible after RSVP deletes its local HTML; reloading that tab can fail after cleanup.
- Escape is handled when RSVP is focused. If the browser is in front, the user returns to RSVP before closing it.

## Links

- Source issue: [ISSUE-20261001-rsvp-html-infographic-hjkl-shortcuts-cleanup](../issues/ISSUE-20261001-rsvp-html-infographic-hjkl-shortcuts-cleanup.md)
- Related spec: [SPEC-rsvp-html-infographic](../specs/SPEC-rsvp-html-infographic.md)
- Current behavior: [GUIDE-rsvp-clipboard](../guides/GUIDE-rsvp-clipboard.md)
