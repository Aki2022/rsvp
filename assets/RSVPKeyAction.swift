import Foundation

enum RSVPKeyAction: Equatable {
    case escape
    case pause
    case summary
    case diagram
    case quiz
    case diagnostics
    case quizAnswer(RSVPQuizChoice)
    case speedChange(Int)
    case seek(TimeInterval)

    static func action(for keyCode: UInt16) -> RSVPKeyAction? {
        switch keyCode {
        case 53:
            return .escape
        case 49:
            return .pause
        case 1:
            return .summary
        case 3:
            return .diagram
        case 12:
            return .quiz
        case 2:
            return .diagnostics
        case 0:
            return .quizAnswer(.a)
        case 11:
            return .quizAnswer(.b)
        case 8:
            return .quizAnswer(.c)
        case 126, 40:
            return .speedChange(25)
        case 125, 38:
            return .speedChange(-25)
        case 123, 4:
            return .seek(-10)
        case 124, 37:
            return .seek(10)
        default:
            return nil
        }
    }
}
