#!/bin/sh
set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
temporary_directory=${TMPDIR:-/tmp}
test_directory=$(mktemp -d "${temporary_directory%/}/rsvp-swift-tests.XXXXXX")
trap 'rm -rf "$test_directory"' EXIT HUP INT TERM

swiftc_path=$(command -v swiftc)
"$swiftc_path" \
  -module-cache-path "$test_directory/module-cache" \
  "$repository_root/assets/RSVPKeyAction.swift" \
  "$repository_root/assets/RSVPTextCleaner.swift" \
  "$repository_root/assets/RSVPQuiz.swift" \
  "$repository_root/assets/RSVPQuizPresentation.swift" \
  "$repository_root/assets/RSVPCLIDiagnostics.swift" \
  "$repository_root/assets/RSVPDiagramHTML.swift" \
  "$repository_root/assets/RSVPDiagramStore.swift" \
  "$repository_root/tests/RSVPHelpersTests.swift" \
  -o "$test_directory/rsvp-helper-tests"

"$test_directory/rsvp-helper-tests"
