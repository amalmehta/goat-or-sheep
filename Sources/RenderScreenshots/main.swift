// Renders README screenshots of the Mac app's screens and the website into docs/screenshots/.
// Usage (from the repo root): swift run -c release RenderScreenshots [output-dir]
// (A debug build works too, but PNG.swift makes it take minutes instead of seconds.)
import AppKit
import SwiftUI
import WebKit
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
    PNG.write(rep.cgImage!, to: path)
    print("wrote \(path)")
}

/// Runs the main run loop until `done` returns true, so WebKit can load and draw.
@MainActor
func spin(until done: () -> Bool, timeout: TimeInterval = 20) {
    let end = Date().addingTimeInterval(timeout)
    while !done() && Date() < end { RunLoop.main.run(mode: .default, before: Date().addingTimeInterval(0.05)) }
    if !done() { fatalError("timed out waiting for the website to render") }
}

final class PageLoader: NSObject, WKNavigationDelegate {
    var finished = false
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { finished = true }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { fatalError("\(error)") }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { fatalError("\(error)") }
}

/// Renders web/index.html's start screen at `width`×`height` points, saved at `scale`× pixels.
@MainActor
func renderWebsite(width: CGFloat, height: CGFloat, scale: CGFloat, appearance: NSAppearance.Name, to path: String) {
    let web = WKWebView(frame: NSRect(x: 0, y: 0, width: width, height: height))
    web.appearance = NSAppearance(named: appearance)
    let window = NSWindow(contentRect: web.frame, styleMask: [.borderless], backing: .buffered, defer: false)
    window.contentView = web

    let loader = PageLoader()
    web.navigationDelegate = loader
    let page = URL(fileURLWithPath: "web/index.html").absoluteURL
    web.loadFileURL(page, allowingReadAccessTo: page.deletingLastPathComponent())
    spin { loader.finished }

    // The page uses Google Fonts; wait for them so the text isn't drawn in a fallback font.
    var fontsLoaded: Bool?
    let checkFonts = """
        await document.fonts.ready;
        const loaded = family => [...document.fonts].some(f => f.family.includes(family) && f.status === "loaded");
        return loaded("Baloo 2") && loaded("Figtree");
        """
    web.callAsyncJavaScript(checkFonts, arguments: [:], in: nil, in: .page) { result in
        fontsLoaded = (try? result.get()) as? Bool ?? false
    }
    spin { fontsLoaded != nil }
    if fontsLoaded != true { fatalError("the website's Google Fonts didn't load; check the internet connection") }
    RunLoop.main.run(until: Date().addingTimeInterval(0.3))

    let config = WKSnapshotConfiguration()
    config.snapshotWidth = NSNumber(value: Double(width * scale))
    var snapshot: NSImage?
    web.takeSnapshot(with: config) { image, error in
        if let error { fatalError("\(error)") }
        snapshot = image
    }
    spin { snapshot != nil }

    // Redraw into a bitmap of exactly width×scale by height×scale pixels, whatever the screen's scale.
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(width * scale), pixelsHigh: Int(height * scale),
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.imageInterpolation = .high
    snapshot!.draw(in: NSRect(x: 0, y: 0, width: rep.pixelsWide, height: rep.pixelsHigh))
    NSGraphicsContext.restoreGraphicsState()
    PNG.write(rep.cgImage!, to: path)
    print("wrote \(path)")
}

MainActor.assumeIsolated {
    _ = NSApplication.shared
    let out = CommandLine.arguments.dropFirst().first ?? "docs/screenshots"
    try! FileManager.default.createDirectory(atPath: out, withIntermediateDirectories: true)

    let q = Quiz.questions
    let goatPicks = q.enumerated().map { i, question in
        question.answers.first { $0.animal == (i < 10 ? .goat : .sheep) }!
    }

    render(QuizState(screen: .start), appearance: .aqua, to: "\(out)/start.png")
    render(QuizState(screen: .question(3), picks: Array(goatPicks.prefix(3))), appearance: .aqua, to: "\(out)/question.png")
    render(QuizState(screen: .result, picks: goatPicks), appearance: .aqua, to: "\(out)/result-goat.png")

    render(QuizState(screen: .start), appearance: .darkAqua, to: "\(out)/start-dark.png")
    render(QuizState(screen: .question(3), picks: Array(goatPicks.prefix(3))), appearance: .darkAqua, to: "\(out)/question-dark.png")
    render(QuizState(screen: .result, picks: goatPicks), appearance: .darkAqua, to: "\(out)/result-goat-dark.png")

    renderWebsite(width: 1200, height: 760, scale: 2, appearance: .aqua, to: "\(out)/website.png")
    renderWebsite(width: 1200, height: 760, scale: 2, appearance: .darkAqua, to: "\(out)/website-dark.png")
    renderWebsite(width: 390, height: 844, scale: 3, appearance: .aqua, to: "\(out)/website-phone.png")
    renderWebsite(width: 390, height: 844, scale: 3, appearance: .darkAqua, to: "\(out)/website-phone-dark.png")
}
