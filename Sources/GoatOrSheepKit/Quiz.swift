import Foundation

public enum Animal: String, CaseIterable, Sendable {
    case goat, sheep

    public var name: String { self == .goat ? "Goat" : "Sheep" }
    public var emoji: String { self == .goat ? "🐐" : "🐑" }

    public var blurb: String {
        switch self {
        case .goat:
            return "You pick your own path, even when it's a cliff face. Curious, stubborn in the best way, and willing to try anything once, including the thing nobody else will eat."
        case .sheep:
            return "You know there's strength in the flock. Calm, loyal, and easy to be around, you keep the group together and rarely end up stuck on a ledge."
        }
    }
}

public struct Answer: Hashable, Sendable {
    public let text: String
    public let animal: Animal
}

public struct Question: Hashable, Sendable {
    public let prompt: String
    public let answers: [Answer]
}

public struct QuizResult: Equatable, Sendable {
    public let goatCount: Int
    public let total: Int

    public init(goatCount: Int, total: Int) {
        self.goatCount = goatCount
        self.total = total
    }

    public var goatShare: Double { total == 0 ? 0 : Double(goatCount) / Double(total) }

    /// With an odd number of questions there's never a tie.
    public var animal: Animal { goatCount * 2 > total ? .goat : .sheep }
}

public enum Quiz {
    private static func g(_ t: String) -> Answer { Answer(text: t, animal: .goat) }
    private static func s(_ t: String) -> Answer { Answer(text: t, animal: .sheep) }

    public static let questions: [Question] = [
        Question(prompt: "Your friends pick a restaurant you don't love. You…", answers: [
            g("Pitch a better place and book it"),
            s("Go. It's about the company"),
            g("Go, but order something off-menu"),
            s("Read the reviews everyone else is reading"),
        ]),
        Question(prompt: "A new app everyone's talking about comes out. You…", answers: [
            s("Download it because everyone did"),
            g("Already tried it last month"),
            s("Wait and see if it sticks"),
            g("Skip it. You like your own setup"),
        ]),
        Question(prompt: "Your ideal weekend is…", answers: [
            s("A group trip someone else planned"),
            g("A solo hike somewhere steep"),
            s("Whatever the group decides"),
            g("A project you've been obsessing over"),
        ]),
        Question(prompt: "In a meeting, your idea gets ignored. You…", answers: [
            g("Bring it up again, louder"),
            s("Let it go. The team has momentum"),
            g("Build a prototype and show them"),
            s("Back the idea that's winning"),
        ]),
        Question(prompt: "Rules are…", answers: [
            s("There for a reason"),
            g("Suggestions"),
            s("What keeps things fair"),
            g("Mostly for other people"),
        ]),
        Question(prompt: "At a buffet you…", answers: [
            g("Try one of everything, weird stuff first"),
            s("Follow the line and take what's popular"),
            g("Go straight for dessert"),
            s("Stick to what you know"),
        ]),
        Question(prompt: "Your phone's home screen is…", answers: [
            s("Untouched since the day you got it"),
            g("A system only you understand"),
            s("The same apps as your friends"),
            g("One page, nothing extra"),
        ]),
        Question(prompt: "You're lost in a new city. You…", answers: [
            s("Follow the crowd. They probably know"),
            g("Pick a direction and commit"),
            s("Ask someone for directions"),
            g("Climb something to get a better view"),
        ]),
        Question(prompt: "Pick a motto.", answers: [
            s("Safety in numbers"),
            g("Why walk when you can climb?"),
            s("Go with the flow"),
            g("Eat first, ask questions later"),
        ]),
    ]

    public static func score(_ picks: [Answer]) -> QuizResult {
        QuizResult(goatCount: picks.filter { $0.animal == .goat }.count, total: picks.count)
    }
}
