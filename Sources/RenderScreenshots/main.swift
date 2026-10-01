// Renders README screenshots of each screen into docs/screenshots/.
// Usage: swift run RenderScreenshots [output-dir]
import AppKit
import SwiftUI
import GoatOrSheepKit

@MainActor
func render(_ state: QuizState, appearance: NSAppearance.Name, to path: String) {
    let view = NSHostingView(rootView: ContentView(state: state, feedbackRecipient: "you@example.com"))
    view.frame = NSRect(x: 0, y: 0, width: 560, height: 520)
    let window = NSWindow(contentRect: view.frame, styleMask: [.borderless], backing: .buffered, defer: false)
    window.appearance = NSAppearance(named: appearance)
    window.contentView = view
    view.layoutSubtreeIfNeeded()
    RunLoop.main.run(until: Date().addingTimeInterval(0.3))

    guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return }
    view.cacheDisplay(in: view.bounds, to: rep)
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
    print("wrote \(path)")
}

MainActor.assumeIsolated {
    _ = NSApplication.shared
    let out = CommandLine.arguments.dropFirst().first ?? "docs/screenshots"
    try! FileManager.default.createDirectory(atPath: out, withIntermediateDirectories: true)

    let q = Quiz.questions
    let goatPicks = q.enumerated().map { i, question in
        question.answers.first { $0.animal == (i < 6 ? .goat : .sheep) }!
    }
    let sheepPicks = q.enumerated().map { i, question in
        question.answers.first { $0.animal == (i < 2 ? .goat : .sheep) }!
    }

    render(QuizState(screen: .start), appearance: .aqua, to: "\(out)/start.png")
    render(QuizState(screen: .question(3), picks: Array(goatPicks.prefix(3))), appearance: .aqua, to: "\(out)/question.png")
    render(QuizState(screen: .result, picks: goatPicks), appearance: .aqua, to: "\(out)/result-goat.png")
    render(QuizState(screen: .result, picks: sheepPicks), appearance: .aqua, to: "\(out)/result-sheep.png")

    render(QuizState(screen: .start), appearance: .darkAqua, to: "\(out)/start-dark.png")
    render(QuizState(screen: .question(3), picks: Array(goatPicks.prefix(3))), appearance: .darkAqua, to: "\(out)/question-dark.png")
    render(QuizState(screen: .result, picks: goatPicks), appearance: .darkAqua, to: "\(out)/result-goat-dark.png")
    render(QuizState(screen: .result, picks: sheepPicks), appearance: .darkAqua, to: "\(out)/result-sheep-dark.png")
}
