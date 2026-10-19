import json
import pathlib
import re
import subprocess
import tempfile
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
SOURCE_PATH = ROOT / "assets" / "rsvp.swift"


class SummaryEnvironmentBridgeTests(unittest.TestCase):
    def test_login_shell_context_is_captured_without_provider_credentials(self):
        source = SOURCE_PATH.read_text(encoding="utf-8")
        match = re.search(
            r'^\s*"(?P<script>command_path=.*RSVP_SHELL_ENV_V1.*)",$',
            source,
            re.MULTILINE,
        )
        self.assertIsNotNone(match, "the production login-shell bridge script must exist")
        shell_script = json.loads(f'"{match.group("script")}"')

        with tempfile.TemporaryDirectory(prefix="rsvp-shell-env-test-") as temporary:
            root = pathlib.Path(temporary)
            home = root / "home"
            zdotdir = root / "zsh"
            bin_directory = root / "bin"
            for directory in (home, zdotdir, bin_directory):
                directory.mkdir(parents=True, exist_ok=True)

            fake_cli = bin_directory / "claude2"
            fake_cli.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
            fake_cli.chmod(0o755)

            (zdotdir / ".zprofile").write_text(
                f'export PATH="{bin_directory}:/usr/bin:/bin"\n', encoding="utf-8"
            )
            (zdotdir / ".zshrc").write_text(
                'export CLAUDE_CONFIG_DIR="/fixture/claude-config"\n'
                'export CLAUDE_CODE_OAUTH_TOKEN="fixture-oauth-access"\n'
                'export CLAUDE_CODE_OAUTH_REFRESH_TOKEN="fixture-oauth-refresh"\n'
                'export CLAUDE_CODE_OAUTH_SCOPES="user:profile user:inference"\n'
                'export ANTHROPIC_API_KEY="fixture-api-key-must-not-pass"\n',
                encoding="utf-8",
            )
            (zdotdir / ".zlogin").write_text(
                'print -r -- startup-noise\n', encoding="utf-8"
            )
            (zdotdir / ".zlogout").write_text(
                'print -r -- logout-noise\n', encoding="utf-8"
            )

            result = subprocess.run(
                [
                    "/bin/zsh",
                    "-lic",
                    shell_script,
                    "rsvp-command-resolution",
                    "claude2",
                ],
                env={
                    "HOME": str(home),
                    "ZDOTDIR": str(zdotdir),
                    "PATH": "/usr/bin:/bin",
                    "ANTHROPIC_API_KEY": "inherited-api-key-must-not-pass",
                    "CLAUDE_CONFIG_DIR": "/raycast/old-config",
                    "CLAUDE_CODE_OAUTH_TOKEN": "raycast-old-token",
                },
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                check=True,
            )

            fields = result.stdout.split(b"\0")
            marker_index = fields.index(b"RSVP_SHELL_ENV_V1")
            values = fields[marker_index + 1 : marker_index + 8]
            self.assertEqual(
                values,
                [
                    f"{bin_directory}:/usr/bin:/bin".encode(),
                    str(home).encode(),
                    b"/fixture/claude-config",
                    b"fixture-oauth-access",
                    b"fixture-oauth-refresh",
                    b"user:profile user:inference",
                    str(fake_cli).encode(),
                ],
            )
            self.assertNotIn(b"fixture-api-key-must-not-pass", result.stdout)
            self.assertNotIn(b"inherited-api-key-must-not-pass", result.stdout)

            absolute_path_result = subprocess.run(
                [
                    "/bin/zsh",
                    "-lic",
                    shell_script,
                    "rsvp-command-resolution",
                    "",
                ],
                env={
                    "HOME": str(home),
                    "ZDOTDIR": str(zdotdir),
                    "PATH": "/usr/bin:/bin",
                },
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                check=True,
            )
            absolute_fields = absolute_path_result.stdout.split(b"\0")
            absolute_marker = absolute_fields.index(b"RSVP_SHELL_ENV_V1")
            absolute_values = absolute_fields[absolute_marker + 1 : absolute_marker + 8]
            self.assertEqual(absolute_values[0], f"{bin_directory}:/usr/bin:/bin".encode())
            self.assertEqual(absolute_values[2], b"/fixture/claude-config")
            self.assertEqual(absolute_values[3], b"fixture-oauth-access")
            self.assertEqual(absolute_values[6], b"")

    def test_summary_cli_uses_restricted_subscription_only_environment(self):
        source = SOURCE_PATH.read_text(encoding="utf-8")
        self.assertIn('isAbsolutePath ? "" : configuredCommand', source)
        self.assertIn('variable.hasPrefix("ANTHROPIC_")', source)
        self.assertIn('"AWS_BEARER_TOKEN_BEDROCK"', source)
        self.assertIn('"CLAUDE_CODE_USE_BEDROCK"', source)
        self.assertIn('"CLAUDE_CODE_USE_VERTEX"', source)
        self.assertIn('"--safe-mode"', source)
        self.assertIn('"--restricted"', source)

    def test_auth_failure_reports_only_safe_environment_categories(self):
        source = SOURCE_PATH.read_text(encoding="utf-8")
        match = re.search(
            r"private func safeAuthenticationContext\(from environment: \[String: String\]\) -> String \{(?P<body>.*?)\n\}",
            source,
            re.DOTALL,
        )
        self.assertIsNotNone(match, "the failure-only safe auth context must exist")
        body = match.group("body")
        self.assertIn('environment["CLAUDE_CONFIG_DIR"]', body)
        self.assertIn('environment["CLAUDE_CODE_OAUTH_TOKEN"]', body)
        self.assertIn('environment["CLAUDE_CODE_OAUTH_REFRESH_TOKEN"]', body)
        self.assertIn("Keychain=未確認", body)
        self.assertNotRegex(body, r'\\\(environment\["CLAUDE_(?:CONFIG_DIR|CODE_OAUTH_[A-Z_]+)"\]')

        error_match = re.search(
            r"private func cliErrorDetail\(.*?\n    \}\n\n    private func formattedDuration",
            source,
            re.DOTALL,
        )
        self.assertIsNotNone(error_match)
        self.assertIn("RSVPCLIDiagnostics.detail(", error_match.group(0))
        self.assertIn("response.authenticationContext", error_match.group(0))
        diagnostics = (ROOT / "assets" / "RSVPCLIDiagnostics.swift").read_text(encoding="utf-8")
        self.assertIn("authenticationContext", diagnostics)
        self.assertIn("standardErrorByteCount", diagnostics)
        self.assertNotIn("return standardError", diagnostics)

    def test_raycast_launches_a_signed_reader_app_bundle_with_private_input_handoff(self):
        source = SOURCE_PATH.read_text(encoding="utf-8")
        launcher = (ROOT / "src" / "rsvp-clipboard.js").read_text(encoding="utf-8")
        package = json.loads((ROOT / "package.json").read_text(encoding="utf-8"))

        self.assertIn('"RSVPReader.app"', launcher)
        self.assertIn('"/usr/bin/open"', launcher)
        self.assertIn('"-n", "-a"', launcher)
        self.assertIn("mode: 0o600", launcher)
        self.assertIn("chmod(handoffDirectory, 0o700)", launcher)
        self.assertIn("inputPath", launcher)
        self.assertNotIn('String(clipboardText)', launcher)
        self.assertIn("build-reader-app.mjs", package["scripts"]["build:reader"])
        build_script = (ROOT / "scripts" / "build-reader-app.mjs").read_text(encoding="utf-8")
        self.assertIn("RSVPReader.app", build_script)
        self.assertIn("Contents", build_script)
        self.assertIn("MacOS", build_script)
        self.assertIn("RSVPReader", build_script)
        self.assertIn("--identifier", build_script)
        self.assertIn("PkgInfo", build_script)
        self.assertIn("APPL????", build_script)
        self.assertNotIn("RSVP_E2E_TEST", source)
        self.assertNotIn("--e2e-summary", source)
        self.assertNotIn("RSVP_E2E_TEST", build_script)
        self.assertIn("readerInputPath", source)
        self.assertIn("readerStatusPath", source)
        self.assertIn("RSVP_READER_READY", source)

    def test_diagram_prompt_and_helper_sources_are_wired_into_reader_build(self):
        source = SOURCE_PATH.read_text(encoding="utf-8")
        launcher = (ROOT / "src" / "rsvp-clipboard.js").read_text(encoding="utf-8")
        prompt = (ROOT / "assets" / "diagram-prompt.md").read_text(encoding="utf-8")
        build_script = (ROOT / "scripts" / "build-reader-app.mjs").read_text(encoding="utf-8")

        self.assertIn('ensurePromptFile("diagram.md", "diagram-prompt.md")', launcher)
        self.assertIn("statusPath, diagramPromptPath", launcher)
        self.assertIn("configuredDiagramPromptPath = CommandLine.arguments.dropFirst(6).first", source)
        self.assertIn("RSVPKeyAction.action(for: keyCode)", source)
        self.assertIn("RSVPDiagramHTML.prepare(response.output)", source)
        self.assertIn("NSWorkspace.shared.open(htmlURL)", source)
        self.assertIn("diagramStore?.cleanup()", source)
        self.assertIn("maximumOutputBytes: RSVPDiagramHTML.maximumByteCount", source)
        self.assertIn("outputTruncated", source)
        self.assertIn("RSVPDiagramStore.swift", build_script)
        self.assertIn("JavaScript", prompt)
        self.assertIn("外部通信", prompt)
        self.assertNotIn("ANTHROPIC_API_KEY", source)

    def test_quiz_prompt_and_helpers_are_wired_without_an_api_path(self):
        source = SOURCE_PATH.read_text(encoding="utf-8")
        launcher = (ROOT / "src" / "rsvp-clipboard.js").read_text(encoding="utf-8")
        prompt = (ROOT / "assets" / "quiz-prompt.md").read_text(encoding="utf-8")
        quiz = (ROOT / "assets" / "RSVPQuiz.swift").read_text(encoding="utf-8")
        cleaner = (ROOT / "assets" / "RSVPTextCleaner.swift").read_text(encoding="utf-8")
        build_script = (ROOT / "scripts" / "build-reader-app.mjs").read_text(encoding="utf-8")

        self.assertIn('return ensureEditablePromptFile({', launcher)
        self.assertIn('ensurePromptFile("quiz.md", "quiz-prompt.md")', launcher)
        self.assertIn("const quizPromptPath = await ensureQuizPromptFile()", launcher)
        self.assertIn("statusPath, diagramPromptPath, quizPromptPath", launcher)
        self.assertIn("configuredQuizPromptPath = CommandLine.arguments.dropFirst(7).first", source)
        self.assertIn("loadQuizRequest(promptPath: promptPath, source: source)", source)
        self.assertIn("maximumOutputBytes: RSVPQuiz.maximumResponseBytes", source)
        self.assertIn("displayView.onQuiz =", source)
        self.assertIn("displayView.onQuizAnswer =", source)
        self.assertIn("quizSession.answer(choice)", source)
        self.assertIn("restoreAfterQuiz(status: \"\", resumePlayback: false)", source)
        key_actions = (ROOT / "assets" / "RSVPKeyAction.swift").read_text(encoding="utf-8")
        self.assertIn("return .quiz", key_actions)
        self.assertIn("return .quizAnswer(.a)", key_actions)
        self.assertIn("return .quizAnswer(.b)", key_actions)
        self.assertIn("return .quizAnswer(.c)", key_actions)
        self.assertIn('"RSVPQuiz.swift"', build_script)
        self.assertIn('"RSVPCLIDiagnostics.swift"', build_script)
        self.assertIn('"RSVPTextCleaner.swift"', build_script)
        self.assertIn("maximumQuestionCount = 10", quiz)
        self.assertIn("RSVPTextCleaner.removingURLs", quiz)
        self.assertIn("NSRegularExpression", cleaner)
        self.assertIn("重複しない問題を最大10問", prompt)
        self.assertIn("JSONだけを出力", prompt)
        self.assertNotIn("URLSession", source + quiz)
        self.assertNotIn("ANTHROPIC_API_KEY", source)


if __name__ == "__main__":
    unittest.main()
