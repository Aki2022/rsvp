import Foundation

enum RSVPCLIDiagnostics {
    static func safeStandardErrorExcerpt(
        _ standardError: String,
        request: String,
        homeDirectory: String?
    ) -> String {
        var excerpt = standardError

        if !request.isEmpty {
            excerpt = excerpt.replacingOccurrences(of: request, with: "<本文を伏せました>")
            let characters = Array(request)
            if characters.count >= 12 {
                for start in stride(from: 0, to: characters.count - 11, by: 6) {
                    let fragment = String(characters[start..<(start + 12)])
                    excerpt = excerpt.replacingOccurrences(of: fragment, with: "<本文を伏せました>")
                }
            }
        }

        excerpt = replacing(#"\u001B\[[0-9;]*[A-Za-z]"#, in: excerpt, with: " ")
        excerpt = replacing(#"(?i)https?://[^\s]+"#, in: excerpt, with: "<URL>")
        excerpt = replacing(#"(?i)\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b"#, in: excerpt, with: "<メール>")
        excerpt = replacing(#"(?i)\b(?:ANTHROPIC_[A-Z0-9_]+|CLAUDE_CODE_OAUTH_[A-Z0-9_]+|AWS_[A-Z0-9_]+)\s*=\s*[^\s,;]+"#, in: excerpt, with: "<認証設定>")
        excerpt = replacing(#"(?i)\b(?:ANTHROPIC_[A-Z0-9_]+|CLAUDE_CODE_OAUTH_[A-Z0-9_]+|AWS_[A-Z0-9_]+)\b"#, in: excerpt, with: "<環境変数>")
        excerpt = replacing(#"(?i)\b(?:api[-_ ]?key|access[-_ ]?token|refresh[-_ ]?token|oauth[-_ ]?token|token|secret)(?:\s*[:=]\s*|\s+)[^\s,;]+"#, in: excerpt, with: "<認証情報>")
        excerpt = replacing(#"(?i)\b(?:sk-ant-|sk-)[A-Za-z0-9_-]{8,}"#, in: excerpt, with: "<認証情報>")
        excerpt = replacing(#"(?i)\bbearer\s+[A-Za-z0-9._~+/-]+=*"#, in: excerpt, with: "Bearer <認証情報>")
        excerpt = replacing(#"\b[A-Fa-f0-9]{8}(-[A-Fa-f0-9]{4}){3}-[A-Fa-f0-9]{12}\b"#, in: excerpt, with: "<ID>")
        excerpt = replacing(#"(?<![A-Za-z0-9])/(?:Users|private|var|tmp)/[^\s]+"#, in: excerpt, with: "<ローカルパス>")
        excerpt = replacing(#"(?<![A-Za-z0-9])~/[^\s]+"#, in: excerpt, with: "<ローカルパス>")
        excerpt = replacing(#"(?i)\b[A-Za-z0-9+/=_-]{40,}\b"#, in: excerpt, with: "<文字列を伏せました>")
        if let homeDirectory, !homeDirectory.isEmpty {
            excerpt = excerpt.replacingOccurrences(of: homeDirectory, with: "<ホーム>")
        }
        excerpt = replacing(#"[\p{Cc}]+"#, in: excerpt, with: " ")
        excerpt = replacing(#"\s+"#, in: excerpt, with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return String(excerpt.prefix(320))
    }

    static func detail(
        status: Int32,
        standardOutput: String,
        standardError: String,
        inputFailed: Bool,
        requestByteCount: Int,
        standardOutputByteCount: Int,
        standardErrorByteCount: Int,
        authenticationContext: String
    ) -> String {
        let message = (standardError.isEmpty ? standardOutput : standardError).lowercased()
        let measurements = "stdin \(byteCount(requestByteCount)) / stdout \(byteCount(standardOutputByteCount)) / stderr \(byteCount(standardErrorByteCount))"

        if inputFailed {
            return "CLIへの入力送信に失敗しました · \(measurements)"
        }
        if [
            "keychain", "unable to obtain authorization", "securityd", "errsec",
            "not permitted to access credentials", "credential store",
        ].contains(where: message.contains) {
            return "Claude Codeからキーチェーンを利用できません。RaycastとTerminalの環境差を確認してください · \(authenticationContext)"
        }
        if [
            "not logged in", "not signed in", "not authenticated", "authentication failed",
            "authentication error", "unauthorized", "401 unauthorized", "please log in", "please sign in",
            "sign-in is missing", "auth not active", "no credentials", "login required",
            "run /login", "oauth token", "subscription authentication",
        ].contains(where: message.contains) {
            return "Claude Codeの認証設定を確認してください。RaycastとTerminalの環境差が考えられます · \(authenticationContext)"
        }
        if [
            "prompt is too long", "input is too long", "request is too large",
            "maximum context length", "context window exceeded", "context length exceeded",
            "payload too large", "request entity too large",
        ].contains(where: message.contains) {
            return "入力が長すぎてCLIが処理できませんでした · \(measurements)"
        }
        if ["permission denied", "operation not permitted", "eacces"].contains(where: message.contains) {
            return "CLIまたは設定ファイルへのアクセスが拒否されました · \(measurements)"
        }
        if ["unknown option", "unrecognized option", "invalid option", "unknown argument", "unknown tool"].contains(where: message.contains) {
            return "Claude Codeのバージョンまたは設定を確認してください · \(measurements)"
        }
        if ["rate limit", "usage limit", "overloaded", "quota"].contains(where: message.contains) {
            return "Claude Codeの利用制限を確認してください · \(measurements)"
        }
        if ["network", "connection", "socket", "dns", "timed out", "tls", "certificate"].contains(where: message.contains) {
            return "Claude Codeの接続状態を確認してください · \(measurements)"
        }

        return "CLI終了コード: \(status) · \(measurements)"
    }

    private static func byteCount(_ count: Int) -> String {
        if count >= 1_048_576 {
            return String(format: "%.1fMB", Double(count) / 1_048_576)
        }
        if count >= 1_024 {
            return String(format: "%.1fKB", Double(count) / 1_024)
        }
        return "\(count)B"
    }

    private static func replacing(_ pattern: String, in value: String, with replacement: String) -> String {
        value.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
    }
}
