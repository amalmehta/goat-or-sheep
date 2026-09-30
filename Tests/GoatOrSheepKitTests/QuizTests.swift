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

    func testWebsiteQuestionsMatchApp() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
        let html = try String(contentsOf: root.appendingPathComponent("web/index.html"), encoding: .utf8)
        for q in Quiz.questions {
            XCTAssertTrue(html.contains("[\"\(q.prompt)\", ["), "missing question: \(q.prompt)")
            for a in q.answers {
                XCTAssertTrue(html.contains("[\"\(a.text)\", \"\(a.animal.rawValue)\"]"), "missing or mismatched answer: \(a.text)")
            }
        }
        XCTAssertTrue(html.contains(Animal.goat.blurb))
        XCTAssertTrue(html.contains(Animal.sheep.blurb))
    }
}
