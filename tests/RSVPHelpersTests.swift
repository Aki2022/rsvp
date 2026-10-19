import Foundation
import AppKit

@main
struct RSVPHelpersTests {
    static func main() throws {
        try testKeyActions()
        try testQuizDecodingAndLimits()
        try testQuizPresentation()
        try testQuizSession()
        try testQuizRequestRemovesURLs()
        try testCLIDiagnostics()
        try testURLRemoval()
        try testHTMLValidation()
        try testTemporaryStoreLifecycle()
        try testDefaultTemporaryStoreCleanup()
        print("Swift RSVP helper tests passed")
    }

    private static func testKeyActions() throws {
        let cases: [(UInt16, RSVPKeyAction)] = [
            (53, .escape),
            (49, .pause),
            (1, .summary),
            (3, .diagram),
            (12, .quiz),
            (0, .quizAnswer(.a)),
            (11, .quizAnswer(.b)),
            (8, .quizAnswer(.c)),
            (2, .diagnostics),
            (126, .speedChange(25)),
            (40, .speedChange(25)),
            (125, .speedChange(-25)),
            (38, .speedChange(-25)),
            (123, .seek(-10)),
            (4, .seek(-10)),
            (124, .seek(10)),
            (37, .seek(10)),
        ]

        for (keyCode, expected) in cases {
            try expect(RSVPKeyAction.action(for: keyCode) == expected, "unexpected action for key code \(keyCode)")
        }
        try expect(RSVPKeyAction.action(for: 10) == nil, "unmapped key should be ignored")
    }

    private static func testQuizDecodingAndLimits() throws {
        let quiz = try RSVPQuiz.decode(twoQuestionFixture)
        try expect(quiz.questions.count == 2, "quiz question count changed")
        try expect(quiz.questions[0].question == "何が増えた？", "question text was lost")
        try expect(quiz.questions[0].choices[.b] == "予算", "choice text was lost")
        try expect(quiz.questions[0].correctAnswer == .b, "correct answer was lost")

        let fenced = "```json\n\(twoQuestionFixture)\n```"
        let fencedQuiz = try RSVPQuiz.decode(fenced)
        let emptyQuiz = try RSVPQuiz.decode("{\"questions\":[]}")
        try expect(fencedQuiz.questions.count == 2, "JSON code fences should be accepted")
        try expect(emptyQuiz.questions.isEmpty, "zero questions should signal insufficient content")

        try expectThrows(RSVPQuizError.tooManyQuestions) {
            _ = try RSVPQuiz.decode(String(data: try JSONSerialization.data(withJSONObject: ["questions": Array(repeating: questionObject, count: 11)]), encoding: .utf8)!)
        }
        try expectThrows(RSVPQuizError.invalidResponse) {
            _ = try RSVPQuiz.decode("{\"questions\":[{\"question\":\"x\"}]}")
        }
        try expectThrows(RSVPQuizError.invalidResponse) {
            let duplicate = questionJSON(question: "同じ質問")
            _ = try RSVPQuiz.decode("{\"questions\":[\(duplicate),\(duplicate)]}")
        }
    }

    private static func testQuizSession() throws {
        let questions = try RSVPQuiz.decode(twoQuestionFixture).questions
        var session = RSVPQuizSession(questions: questions)

        try expect(session.questionNumber == 1, "quiz should start on the first question")
        try expect(session.answer(.b) == true, "correct answer was marked wrong")
        try expect(session.answer(.a) == nil, "a locked answer should not be replaceable")
        try expect(session.correctAnswerCount == 1, "correct answer count changed")
        try expect(session.advance() == .nextQuestion, "Space should advance to the next question")
        try expect(session.questionNumber == 2, "question number did not advance")
        try expect(session.answer(.a) == false, "wrong answer was marked correct")
        try expect(session.correctAnswerCount == 1, "wrong answer changed the score")
        try expect(session.advance() == .completed, "last answer should complete the quiz")
        try expect(session.isFinished, "quiz should report completion")
    }

    private static func testQuizPresentation() throws {
        let question = try RSVPQuiz.decode(twoQuestionFixture).questions[0]
        let content = RSVPQuizPresentation.question(question, number: 2, total: 10)
        try expect(content.string.contains("何が増えた？"), "quiz question was omitted from its display content")
        try expect(content.string.contains("A  売上"), "choice A was omitted from quiz display content")
        try expect(content.string.contains("B  予算"), "choice B was omitted from quiz display content")
        try expect(content.string.contains("C  人員"), "choice C was omitted from quiz display content")

        let storage = NSTextStorage(attributedString: content)
        let layoutManager = NSLayoutManager()
        let container = NSTextContainer(containerSize: NSSize(width: 700, height: CGFloat.greatestFiniteMagnitude))
        container.lineFragmentPadding = 0
        container.lineBreakMode = NSLineBreakMode.byCharWrapping
        layoutManager.addTextContainer(container)
        storage.addLayoutManager(layoutManager)
        layoutManager.ensureLayout(for: container)
        let glyphRange = layoutManager.glyphRange(for: container)
        try expect(NSMaxRange(glyphRange) == layoutManager.numberOfGlyphs, "quiz display layout clipped content")
        try expect(layoutManager.usedRect(for: container).height > 150, "quiz content was laid out as a single oversized RSVP token")

        let diagnostic = RSVPQuizPresentation.diagnostic("Error: synthetic CLI failure")
        try expect(diagnostic.string.contains("CLI診断"), "diagnostic view should be labeled")
        try expect(diagnostic.string.contains("synthetic CLI failure"), "diagnostic details were omitted")
    }

    private static func testQuizRequestRemovesURLs() throws {
        let request = try RSVPQuiz.makeRequest(
            prompt: "編集可能なプロンプト",
            source: "本文の事実。 https://example.test/path\n結論。"
        )

        try expect(request.contains("編集可能なプロンプト"), "user prompt was not included")
        try expect(request.contains("本文の事実。"), "source text was not included")
        try expect(request.contains("結論。"), "source tail was lost")
        try expect(!request.contains("example.test"), "URL was sent to the quiz prompt")
        try expect(request.contains("信頼できない"), "source safety boundary was omitted")
    }

    private static func testCLIDiagnostics() throws {
        let authContext = "login-zsh · config=default · OAuth env=none · Keychain=未確認"
        let auth = RSVPCLIDiagnostics.detail(
            status: 1,
            standardOutput: "",
            standardError: "Not logged in. Run /login to authenticate.",
            inputFailed: false,
            requestByteCount: 2_048,
            standardOutputByteCount: 0,
            standardErrorByteCount: 45,
            authenticationContext: authContext
        )
        try expect(auth.contains("認証設定"), "authentication errors should be classified")
        try expect(auth.contains(authContext), "authentication diagnostics should include safe environment categories")

        let tooLong = RSVPCLIDiagnostics.detail(
            status: 1,
            standardOutput: "",
            standardError: "Prompt is too long",
            inputFailed: false,
            requestByteCount: 2_048,
            standardOutputByteCount: 0,
            standardErrorByteCount: 18,
            authenticationContext: authContext
        )
        try expect(tooLong.contains("入力が長すぎて"), "oversized prompts should be classified")

        let secretOutput = "CLIPBOARD_SECRET_DO_NOT_DISPLAY"
        let unknown = RSVPCLIDiagnostics.detail(
            status: 1,
            standardOutput: secretOutput,
            standardError: "Unhandled synthetic failure",
            inputFailed: false,
            requestByteCount: 2_048,
            standardOutputByteCount: secretOutput.utf8.count,
            standardErrorByteCount: 27,
            authenticationContext: authContext
        )
        try expect(unknown.contains("CLI終了コード: 1"), "unclassified errors should include the exit code")
        try expect(unknown.contains("stdin 2.0KB / stdout 31B / stderr 27B"), "unclassified errors should include safe byte counts")
        try expect(!unknown.contains(secretOutput), "diagnostics must not reveal CLI output or clipboard text")

        let request = "PRIVATE_CLIPBOARD_PHRASE_2026_DO_NOT_LEAK"
        let excerpt = RSVPCLIDiagnostics.safeStandardErrorExcerpt(
            "Error: /tmp/rsvp-fixture/Private/RSVP failed; token=sk-ant-abcdefghijklmnopqrstuvwxyz; api key plain-secret; " +
                "email=a@example.test https://example.test/private \(request)",
            request: request,
            homeDirectory: "/tmp/rsvp-fixture"
        )
        try expect(excerpt.contains("Error:"), "safe diagnostics should retain the error summary")
        try expect(!excerpt.contains("PRIVATE_CLIPBOARD_PHRASE"), "safe diagnostics must redact echoed clipboard text")
        try expect(!excerpt.contains("/tmp/rsvp-fixture"), "safe diagnostics must redact local paths")
        try expect(!excerpt.contains("Private/RSVP"), "safe diagnostics must redact the rest of local paths")
        try expect(!excerpt.contains("sk-ant-"), "safe diagnostics must redact credentials")
        try expect(!excerpt.contains("plain-secret"), "safe diagnostics must redact labeled API key values")
        try expect(!excerpt.contains("ANTHROPIC_API_KEY"), "safe diagnostics must redact environment variable names")
        try expect(!excerpt.contains("a@example.test"), "safe diagnostics must redact email addresses")
        try expect(!excerpt.contains("https://"), "safe diagnostics must redact URLs")
    }

    private static func testURLRemoval() throws {
        let cleaned = RSVPTextCleaner.removingURLs(from: "事実 https://example.test/a。次の事実 www.example.org/path!")
        try expect(!cleaned.contains("example.test"), "HTTPS URL was not removed")
        try expect(!cleaned.contains("example.org"), "www URL was not removed")
        try expect(cleaned.contains("事実"), "text before a URL was lost")
        try expect(cleaned.contains("次の事実"), "text after a URL was lost")
    }

    private static let questionObject: [String: Any] = [
        "question": "何が増えた？",
        "choices": ["a": "売上", "b": "予算", "c": "人員"],
        "correctAnswer": "b",
        "explanation": "資料では予算の増加を説明している。",
    ]

    private static func questionJSON(question: String) -> String {
        let object: [String: Any] = [
            "question": question,
            "choices": ["a": "売上", "b": "予算", "c": "人員"],
            "correctAnswer": "b",
            "explanation": "資料では予算の増加を説明している。",
        ]
        let data = try! JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
        return String(data: data, encoding: .utf8)!
    }

    private static let twoQuestionFixture = """
    {"questions":[
      {"question":"何が増えた？","choices":{"a":"売上","b":"予算","c":"人員"},"correctAnswer":"b","explanation":"資料では予算の増加を説明している。"},
      {"question":"いつ発表した？","choices":{"a":"4月","b":"5月","c":"6月"},"correctAnswer":"c","explanation":"資料は6月の発表と述べている。"}
    ]}
    """

    private static func testHTMLValidation() throws {
        let validHTML = """
        <!doctype html>
        <html><head><title>Diagram</title><style>body { color: #222; }</style></head>
        <body><h1>要点</h1><svg viewBox="0 0 10 10"><circle cx="5" cy="5" r="4"/></svg></body></html>
        """
        let prepared = try RSVPDiagramHTML.prepare("```html\n\(validHTML)\n```")
        try expect(prepared.contains("Content-Security-Policy"), "CSP was not injected")
        try expect(prepared.contains("script-src 'none'"), "scripts are not blocked")
        try expect(prepared.contains("connect-src 'none'"), "network connections are not blocked")
        try expect(prepared.contains("要点"), "diagram content was lost")

        try expectThrows(RSVPDiagramHTMLError.activeContent) {
            _ = try RSVPDiagramHTML.prepare("<!doctype html><html><head></head><body><script>alert(1)</script></body></html>")
        }
        try expectThrows(RSVPDiagramHTMLError.activeContent) {
            _ = try RSVPDiagramHTML.prepare("<!doctype html><html><head></head><body><meta http-equiv='refresh' content='0;url=https://example.com'></body></html>")
        }
        try expectThrows(RSVPDiagramHTMLError.activeContent) {
            _ = try RSVPDiagramHTML.prepare("<!doctype html><html><head></head><body><a href='https://example.com'>link</a></body></html>")
        }
        try expectThrows(RSVPDiagramHTMLError.invalidDocument) {
            _ = try RSVPDiagramHTML.prepare("<html>missing document structure</html>")
        }
        try expectThrows(RSVPDiagramHTMLError.tooLarge) {
            _ = try RSVPDiagramHTML.prepare(String(repeating: "x", count: RSVPDiagramHTML.maximumByteCount + 1))
        }
    }

    private static func testTemporaryStoreLifecycle() throws {
        let fileManager = FileManager.default
        let temporaryDirectory = fileManager.temporaryDirectory
            .appendingPathComponent("rsvp-helper-tests-\(UUID().uuidString)", isDirectory: true)
        try fileManager.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: temporaryDirectory) }

        let rootURL = temporaryDirectory.appendingPathComponent(RSVPDiagramStore.rootDirectoryName, isDirectory: true)
        let staleURL = rootURL.appendingPathComponent("session-orphan", isDirectory: true)
        try fileManager.createDirectory(at: staleURL, withIntermediateDirectories: true)
        try Data("orphan".utf8).write(to: staleURL.appendingPathComponent("diagram.html"))

        let firstStore = try RSVPDiagramStore(temporaryDirectory: temporaryDirectory)
        try expect(!fileManager.fileExists(atPath: staleURL.path), "orphan session was not swept")
        let rootPermissions = try permissions(at: firstStore.rootURL)
        let sessionPermissions = try permissions(at: firstStore.sessionURL)
        try expect(rootPermissions == 0o700, "root directory permissions are not private")
        try expect(sessionPermissions == 0o700, "session directory permissions are not private")

        let firstHTML = try firstStore.save("<!doctype html><html><head></head><body>one</body></html>")
        let htmlPermissions = try permissions(at: firstHTML)
        try expect(htmlPermissions == 0o600, "HTML file permissions are not private")
        try expect(fileManager.fileExists(atPath: firstHTML.path), "HTML file was not created")

        let secondStore = try RSVPDiagramStore(temporaryDirectory: temporaryDirectory)
        try expect(fileManager.fileExists(atPath: firstHTML.path), "a live session was swept")
        secondStore.cleanup()
        try expect(fileManager.fileExists(atPath: firstHTML.path), "closing another session removed the live HTML")

        firstStore.removeHTML()
        try expect(!fileManager.fileExists(atPath: firstHTML.path), "HTML was not removed")
        firstStore.cleanup()
        try expect(!fileManager.fileExists(atPath: rootURL.path), "empty RSVP temp root was left behind")
    }

    private static func testDefaultTemporaryStoreCleanup() throws {
        let store = try RSVPDiagramStore()
        let sessionURL = store.sessionURL
        store.cleanup()
        try expect(!FileManager.default.fileExists(atPath: sessionURL.path), "default temp session was not removed")
    }

    private static func permissions(at url: URL) throws -> Int {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let permissions = attributes[.posixPermissions] as? NSNumber else {
            throw TestFailure(message: "could not read file permissions for \(url.lastPathComponent)")
        }
        return permissions.intValue & 0o777
    }

    private static func expectThrows<T: Error & Equatable>(
        _ expected: T,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ body: () throws -> Void
    ) throws {
        do {
            try body()
            throw TestFailure(message: "expected error \(expected)", file: file, line: line)
        } catch let actual as T {
            try expect(actual == expected, "unexpected error: \(actual)", file: file, line: line)
        }
    }

    private static func expect(
        _ condition: @autoclosure () -> Bool,
        _ message: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        guard condition() else { throw TestFailure(message: message, file: file, line: line) }
    }
}

private struct TestFailure: Error, CustomStringConvertible {
    let message: String
    let file: StaticString
    let line: UInt

    init(message: String, file: StaticString = #filePath, line: UInt = #line) {
        self.message = message
        self.file = file
        self.line = line
    }

    var description: String { "\(file):\(line): \(message)" }
}
