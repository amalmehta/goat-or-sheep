import JavaScriptCore
import XCTest
@testable import GoatOrSheepKit

final class QuizTests: XCTestCase {
    func testEveryQuestionHasTwoGoatAndTwoSheepAnswers() {
        for q in Quiz.questions {
            XCTAssertEqual(q.answers.filter { $0.animal == .goat }.count, 2, q.prompt)
            XCTAssertEqual(q.answers.filter { $0.animal == .sheep }.count, 2, q.prompt)
        }
    }

    func testOddQuestionCountMeansNoTies() {
        XCTAssertEqual(Quiz.questions.count % 2, 1)
    }

    func testAllGoatAnswersScoreGoat() {
        let picks = Quiz.questions.map { q in q.answers.first { $0.animal == .goat }! }
        let r = Quiz.score(picks)
        XCTAssertEqual(r.animal, .goat)
        XCTAssertEqual(r.goatShare, 1)
    }

    func testMajorityDecides() {
        XCTAssertEqual(QuizResult(goatCount: 5, total: 9).animal, .goat)
        XCTAssertEqual(QuizResult(goatCount: 4, total: 9).animal, .sheep)
        XCTAssertEqual(QuizResult(goatCount: 0, total: 9).animal, .sheep)
    }

    @MainActor
    func testStateFlowAndBack() {
        let s = QuizState()
        s.start()
        XCTAssertEqual(s.screen, .question(0))
        s.choose(Quiz.questions[0].answers[0])
        XCTAssertEqual(s.screen, .question(1))
        s.back()
        XCTAssertEqual(s.screen, .question(0))
        XCTAssertTrue(s.picks.isEmpty)
        for q in Quiz.questions { s.choose(q.answers[1]) }
        XCTAssertEqual(s.screen, .result)
    }

    func testFeedbackMailURLEncodesBody() {
        let url = Feedback.mailURL(to: "a@b.com", body: "hi & bye")!.absoluteString
        XCTAssertTrue(url.hasPrefix("mailto:a@b.com?subject=Goat%20or%20Sheep%20feedback"))
        XCTAssertTrue(url.contains("body=hi%20%26%20bye"))
    }

    // The website keeps its own copy of the quiz in web/quiz.js. These run that file in
    // JavaScriptCore and compare it with the app's, so the two can't drift apart.
    private func websiteQuiz() throws -> JSContext {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
        let js = try String(contentsOf: root.appendingPathComponent("web/quiz.js"), encoding: .utf8)
        let context = try XCTUnwrap(JSContext())
        context.evaluateScript(js)
        XCTAssertNil(context.exception, "web/quiz.js threw: \(context.exception!)")
        return context
    }

    func testWebsiteQuestionsMatchApp() throws {
        let web = try XCTUnwrap(try websiteQuiz().evaluateScript("QUESTIONS").toArray() as? [[Any]])
        let app = Quiz.questions.map { q in [q.prompt, q.answers.map { [$0.text, $0.animal.rawValue] }] as [Any] }
        XCTAssertEqual(web.count, app.count, "website has a different number of questions")
        for (w, a) in zip(web, app) {
            XCTAssertEqual(w[0] as? String, a[0] as? String)
            XCTAssertEqual(w[1] as? [[String]], a[1] as? [[String]], "answers differ for: \(a[0])")
        }
    }

    func testWebsiteAnimalsMatchApp() throws {
        let context = try websiteQuiz()
        for animal in Animal.allCases {
            let web = context.evaluateScript("ANIMALS.\(animal.rawValue)")!
            XCTAssertEqual(web.forProperty("name").toString(), animal.name)
            XCTAssertEqual(web.forProperty("emoji").toString(), animal.emoji)
            XCTAssertEqual(web.forProperty("blurb").toString(), animal.blurb)
        }
    }

    func testWebsiteScoringMatchesApp() throws {
        let score = try XCTUnwrap(try websiteQuiz().objectForKeyedSubscript("score"))
        let total = Quiz.questions.count
        for goats in 0...total {
            let picks = Array(repeating: "goat", count: goats) + Array(repeating: "sheep", count: total - goats)
            let web = score.call(withArguments: [picks.shuffled()])!
            let app = QuizResult(goatCount: goats, total: total)
            XCTAssertEqual(web.forProperty("goats").toInt32(), Int32(app.goatCount))
            XCTAssertEqual(web.forProperty("total").toInt32(), Int32(app.total))
            XCTAssertEqual(web.forProperty("animal").toString(), app.animal.rawValue, "\(goats) goat answers")
        }
    }
}
