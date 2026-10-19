import Foundation

enum RSVPDiagramHTMLError: Error, Equatable {
    case empty
    case tooLarge
    case invalidDocument
    case activeContent
}

enum RSVPDiagramHTML {
    static let maximumByteCount = 1_500_000
    private static let contentSecurityPolicy = "default-src 'none'; img-src data:; style-src 'unsafe-inline'; font-src data:; script-src 'none'; connect-src 'none'; media-src 'none'; object-src 'none'; frame-src 'none'; base-uri 'none'; form-action 'none'"

    static func prepare(_ output: String) throws -> String {
        var html = output.trimmingCharacters(in: .whitespacesAndNewlines)
        if html.hasPrefix("```"), let firstNewline = html.firstIndex(of: "\n"), html.hasSuffix("```") {
            html = String(html[html.index(after: firstNewline)..<html.index(html.endIndex, offsetBy: -3)])
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard !html.isEmpty else { throw RSVPDiagramHTMLError.empty }
        guard html.utf8.count <= maximumByteCount else { throw RSVPDiagramHTMLError.tooLarge }

        let lowercased = html.lowercased()
        guard lowercased.contains("<!doctype html"),
              lowercased.contains("<html"), lowercased.contains("</html>"),
              lowercased.contains("<head"), lowercased.contains("<body"), lowercased.contains("</body>")
        else {
            throw RSVPDiagramHTMLError.invalidDocument
        }

        let forbiddenPatterns = [
            #"<\s*script\b"#,
            #"<\s*iframe\b"#,
            #"<\s*object\b"#,
            #"<\s*embed\b"#,
            #"<\s*form\b"#,
            #"<\s*a\b"#,
            #"\bhref\s*="#,
            #"javascript\s*:"#,
            #"(?is)<meta\b[^>]*http-equiv\s*=\s*["']?\s*refresh\b"#,
        ]
        for pattern in forbiddenPatterns {
            guard let expression = try? NSRegularExpression(pattern: pattern),
                  expression.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)) == nil
            else {
                throw RSVPDiagramHTMLError.activeContent
            }
        }

        guard let headExpression = try? NSRegularExpression(pattern: #"<head\b[^>]*>"#, options: [.caseInsensitive]),
              let headMatch = headExpression.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let headRange = Range(headMatch.range, in: html)
        else {
            throw RSVPDiagramHTMLError.invalidDocument
        }

        let policyTag = "<meta http-equiv=\"Content-Security-Policy\" content=\"\(contentSecurityPolicy)\"><meta charset=\"utf-8\">"
        html.insert(contentsOf: policyTag, at: headRange.upperBound)
        guard html.utf8.count <= maximumByteCount else { throw RSVPDiagramHTMLError.tooLarge }
        return html
    }
}
