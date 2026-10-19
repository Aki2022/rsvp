import AppKit
import Foundation

enum RSVPQuizPresentation {
    static func diagnostic(_ text: String) -> NSAttributedString {
        let result = NSMutableAttributedString(string: "")
        append("CLI診断（標準エラー）\n\n", to: result, size: 19, weight: .semibold, color: .secondaryLabelColor, spacing: 16)
        append(text, to: result, size: 18, weight: .regular, color: .white, spacing: 0)
        return result.copy() as! NSAttributedString
    }

    static func question(
        _ question: RSVPQuizQuestion,
        number: Int,
        total: Int
    ) -> NSAttributedString {
        let result = NSMutableAttributedString(string: "")
        append("問題 \(number) / \(total)\n\n", to: result, size: 17, weight: .medium, color: .secondaryLabelColor, spacing: 14)
        append("\(question.question)\n\n", to: result, size: 32, weight: .bold, color: .white, spacing: 20)

        for choice in RSVPQuizChoice.allCases {
            append("\(choice.label)  ", to: result, size: 25, weight: .bold, color: .systemOrange, spacing: 0)
            append("\(question.choices[choice])\n\n", to: result, size: 25, weight: .medium, color: .white, spacing: 16)
        }

        return result.copy() as! NSAttributedString
    }

    static func feedback(
        _ question: RSVPQuizQuestion,
        selectedAnswer: RSVPQuizChoice,
        isCorrect: Bool,
        finalScore: (correct: Int, total: Int)?
    ) -> NSAttributedString {
        let result = NSMutableAttributedString(string: "")
        append(
            isCorrect ? "正解\n\n" : "不正解\n\n",
            to: result,
            size: 36,
            weight: .bold,
            color: isCorrect ? .systemGreen : .systemOrange,
            spacing: 20
        )
        append(
            "正解: \(question.correctAnswer.label)  \(question.choices[question.correctAnswer])\n\n",
            to: result,
            size: 25,
            weight: .semibold,
            color: .white,
            spacing: 12
        )
        if !isCorrect {
            append(
                "あなたの回答: \(selectedAnswer.label)  \(question.choices[selectedAnswer])\n\n",
                to: result,
                size: 23,
                weight: .medium,
                color: .white,
                spacing: 12
            )
        }
        append("解説\n", to: result, size: 19, weight: .semibold, color: .secondaryLabelColor, spacing: 6)
        append("\(question.explanation)\n\n", to: result, size: 23, weight: .regular, color: .white, spacing: 16)
        if let finalScore {
            append("正解数: \(finalScore.correct) / \(finalScore.total)", to: result, size: 25, weight: .bold, color: .systemOrange, spacing: 0)
        }
        return result.copy() as! NSAttributedString
    }

    private static func append(
        _ text: String,
        to result: NSMutableAttributedString,
        size: CGFloat,
        weight: NSFont.Weight,
        color: NSColor,
        spacing: CGFloat
    ) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.paragraphSpacing = spacing
        let part = NSAttributedString(
            string: text,
            attributes: [
                .font: NSFont.systemFont(ofSize: size, weight: weight),
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle,
            ]
        )
        result.append(part)
    }
}
