import Foundation

enum RSVPTextCleaner {
    static func removingURLs(from source: String) -> String {
        let pattern = #"(?i)(?:https?://|www\.)[^\s<>「」『』。、，！？；：]+|(?<![@\w.-])(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}(?::\d+)?(?:[/?#][^\s<>「」『』。、，！？；：]*)?(?![@\w-])"#
        guard let expression = try? NSRegularExpression(pattern: pattern) else { return source }

        let sourceNSString = source as NSString
        let matches = expression.matches(
            in: source,
            range: NSRange(location: 0, length: sourceNSString.length)
        )
        guard !matches.isEmpty else { return source }

        let trailingPunctuation = CharacterSet(charactersIn: ".,!?;:、。，；：！？")
        var cleaned = source
        for match in matches.reversed() {
            var range = match.range
            while range.length > 0 {
                let lastCharacterRange = NSRange(location: NSMaxRange(range) - 1, length: 1)
                let lastCharacter = sourceNSString.substring(with: lastCharacterRange)
                guard
                    let scalar = lastCharacter.unicodeScalars.first,
                    trailingPunctuation.contains(scalar)
                else {
                    break
                }
                range.length -= 1
            }

            guard range.length > 0 else { continue }
            cleaned = (cleaned as NSString).replacingCharacters(in: range, with: " ")
        }

        return cleaned
            .replacingOccurrences(of: #"[ \t]{2,}"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
