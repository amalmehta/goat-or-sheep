import SwiftUI

public enum Screen: Equatable {
    case start
    case question(Int)
    case result
}

@MainActor
public final class QuizState: ObservableObject {
    @Published public var screen: Screen = .start
    @Published public var picks: [Answer] = []

    public init(screen: Screen = .start, picks: [Answer] = []) {
        self.screen = screen
        self.picks = picks
    }

    public func start() {
        picks = []
        screen = .question(0)
    }

    public func choose(_ answer: Answer) {
        picks.append(answer)
        screen = picks.count < Quiz.questions.count ? .question(picks.count) : .result
    }

    public func back() {
        guard !picks.isEmpty else { screen = .start; return }
        picks.removeLast()
        screen = .question(picks.count)
    }
}

public struct ContentView: View {
    @ObservedObject var state: QuizState
    @State private var showingFeedback = false
    var feedbackRecipient: String

    public init(state: QuizState, feedbackRecipient: String) {
        self.state = state
        self.feedbackRecipient = feedbackRecipient
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                switch state.screen {
                case .start: StartView(state: state)
                case .question(let i): QuestionView(state: state, index: i)
                case .result: ResultView(state: state)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)

            FeedbackTab { showingFeedback = true }
                .padding(12)
        }
        .frame(width: 560, height: 520)
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showingFeedback) {
            FeedbackView(recipient: feedbackRecipient) { showingFeedback = false }
        }
    }
}

struct StartView: View {
    @ObservedObject var state: QuizState

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 24) {
                Text("🐐").font(.system(size: 72))
                Text("or").font(.title).foregroundStyle(.secondary)
                Text("🐑").font(.system(size: 72))
            }
            Text("Goat or Sheep").font(.largeTitle.bold())
            Text("Nine quick questions. Do you climb your own cliff, or stick with the flock?")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 380)
            Button("Take the Quiz") { state.start() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
        }
    }
}

struct QuestionView: View {
    @ObservedObject var state: QuizState
    let index: Int

    var body: some View {
        let question = Quiz.questions[index]
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Button { state.back() } label: { Label("Back", systemImage: "chevron.left") }
                    .buttonStyle(.borderless)
                Spacer()
                Text("Question \(index + 1) of \(Quiz.questions.count)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: Double(index), total: Double(Quiz.questions.count))
            Text(question.prompt)
                .font(.title2.bold())
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 6)
            ForEach(Array(question.answers.enumerated()), id: \.offset) { n, answer in
                Button { state.choose(answer) } label: {
                    Text(answer.text)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .keyboardShortcut(KeyEquivalent(Character("\(n + 1)")), modifiers: [])
            }
            Spacer(minLength: 0)
        }
    }
}

struct ResultView: View {
    @ObservedObject var state: QuizState

    var body: some View {
        let result = Quiz.score(state.picks)
        let animal = result.animal
        VStack(spacing: 16) {
            Text(animal.emoji).font(.system(size: 96))
            Text("You're a \(animal.name).").font(.largeTitle.bold())
            Text(animal.blurb)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)
            VStack(spacing: 6) {
                HStack {
                    Text("🐐 Goat \(result.goatCount)")
                    Spacer()
                    Text("Sheep \(result.total - result.goatCount) 🐑")
                }
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        Rectangle().fill(Color.brown)
                            .frame(width: max(0, geo.size.width * result.goatShare - 1))
                        Rectangle().fill(Color.gray.opacity(0.35))
                    }
                    .clipShape(Capsule())
                }
                .frame(height: 12)
            }
            .frame(maxWidth: 360)
            Button("Take It Again") { state.start() }
                .controlSize(.large)
                .padding(.top, 8)
        }
    }
}

struct FeedbackTab: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Feedback", systemImage: "bubble.left")
                .font(.caption)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .opacity(0.8)
        .help("Send feedback about Goat or Sheep")
    }
}

public struct FeedbackView: View {
    let recipient: String
    var dismiss: () -> Void
    @State private var text = ""

    public init(recipient: String, dismiss: @escaping () -> Void) {
        self.recipient = recipient
        self.dismiss = dismiss
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Send Feedback").font(.headline)
            Text("This opens an email draft in your mail app. Nothing is sent until you send it there.")
                .font(.callout)
                .foregroundStyle(.secondary)
            TextEditor(text: $text)
                .font(.body)
                .frame(minHeight: 140)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3)))
            HStack {
                Spacer()
                Button("Cancel", action: dismiss).keyboardShortcut(.cancelAction)
                Button("Open Email") {
                    if let url = Feedback.mailURL(to: recipient, body: text) {
                        NSWorkspace.shared.open(url)
                    }
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 400)
    }
}

public enum Feedback {
    public static func mailURL(to recipient: String, body: String) -> URL? {
        var c = URLComponents()
        c.scheme = "mailto"
        c.path = recipient
        c.queryItems = [
            URLQueryItem(name: "subject", value: "Goat or Sheep feedback"),
            URLQueryItem(name: "body", value: body),
        ]
        return c.url
    }
}
