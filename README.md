# RSVP Clipboard for Raycast

[日本語](README.ja.md)

RSVP Clipboard is a macOS Raycast extension that reads the text on your clipboard one short phrase at a time in a large, resizable native window. You can also request a summary, a comprehension quiz, or a static infographic from the captured text.

## Features

- Read the clipboard snapshot with adjustable speed and approximate seeking.
- Create a Japanese summary in the reader.
- Generate a multiple-choice comprehension quiz in the reader.
- Create a static HTML infographic and open it in your default browser.
- Edit the prompts used for summaries, quizzes, and infographics.

### Keyboard controls

| Key | Action |
| --- | --- |
| `Space` | Pause or resume; advance through quiz feedback |
| `↑` / `↓`, `k` / `j` | Increase / decrease reading speed by 25 WPM |
| `←` / `→`, `h` / `l` | Seek about 10 seconds backward / forward |
| `s` | Generate a Japanese summary |
| `q` | Generate a comprehension quiz |
| `a` / `b` / `c` | Answer a quiz question |
| `f` | Generate an infographic and open it in the browser |
| `d` | Show a sanitized CLI error excerpt after a quiz failure |
| `Esc` | Close the reader and cancel an active request |

## Requirements

- macOS 15 or later
- Raycast
- Node.js and npm
- Swift and `codesign` (available with the Xcode Command Line Tools) to build the native reader app
- A Claude Code-compatible command for summaries, quizzes, and infographics; the default is `claude2`

## Run locally

```sh
npm install
npm run dev
```

Set the initial speed in Raycast **Settings → Extensions → RSVP Clipboard → Preferences → 読み上げ速度 (WPM)**. The default is 300 WPM; accepted values are integers from 30 to 1200. Arrow and HJKL speed changes apply to the current reader session only.

Set **要約コマンド** to an executable name or absolute path if the default command is not available in Raycast. This command is used for summaries, quizzes, and infographics. The editable prompts are created on first use at:

- `~/Library/Application Support/RSVP Clipboard/summary.md`
- `~/Library/Application Support/RSVP Clipboard/quiz.md`
- `~/Library/Application Support/RSVP Clipboard/diagram.md`

Run the automated checks with:

```sh
npm test
```

## Clipboard and CLI data

The extension captures the clipboard when the reader starts. It hands the snapshot to the native reader through a short-lived, owner-only temporary file and removes the file after the reader loads it. New clipboard contents do not replace the active reading session.

The captured text is passed to the configured CLI only when you press `s`, `q`, or `f`. This repository does not call a model API directly. The configured CLI may send data to a service and may be subject to its own authentication, network, organization, and billing policies; review those policies before using sensitive text. Generated infographics are temporary static HTML, and the reader removes its local file when the session closes.

## Current status and limitations

- This repository is an in-development prototype, not a finished release.
- This is a macOS-only project. Japanese phrase grouping uses Apple Natural Language heuristics and is not a full Japanese grammar parser.
- Quiz responses currently allow up to ten questions, including fewer than ten. The stricter ten-question requirement is still unfinished.
- Infographics are static pages; scripts, links, external fonts, remote images, and network resources are not allowed in the generated HTML.
- This repository provides the source and local development workflow; it does not include a published binary release.

For detailed behavior and limitations, see the [RSVP Clipboard guide](docs/guides/GUIDE-rsvp-clipboard.md).

## Project layout

- `src/` — Raycast command and prompt-file setup
- `assets/` — Swift reader sources, default prompts, and icon
- `scripts/` — native app build script
- `tests/` — helper and packaging behavior checks
- `docs/guides/` — user and maintenance guide

## License

This project is licensed under the [MIT License](LICENSE).
