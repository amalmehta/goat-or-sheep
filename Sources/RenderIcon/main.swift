// Draws the app icon as a 1024×1024 PNG.
// Usage: swift run RenderIcon [output.png]
import AppKit
import SwiftUI

let tan = Color(red: 0.80, green: 0.62, blue: 0.43)
let tanDark = Color(red: 0.62, green: 0.45, blue: 0.29)
let horn = Color(red: 0.36, green: 0.31, blue: 0.28)
let wool = Color(red: 0.98, green: 0.97, blue: 0.94)
let woolShade = Color(red: 0.86, green: 0.84, blue: 0.80)
let sheepFace = Color(red: 0.25, green: 0.23, blue: 0.24)

struct Horn: Shape {
    var flip = false
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.maxY))
        p.addCurve(to: CGPoint(x: r.maxX, y: r.minY + r.height * 0.15),
                   control1: CGPoint(x: r.midX, y: r.minY),
                   control2: CGPoint(x: r.maxX - r.width * 0.1, y: r.minY - r.height * 0.1))
        if flip { p = p.applying(CGAffineTransform(scaleX: -1, y: 1).translatedBy(x: -r.width - 2 * r.minX, y: 0)) }
        return p
    }
}

struct Eye: View {
    var body: some View {
        ZStack {
            Circle().fill(.white).frame(width: 34, height: 34)
            Circle().fill(.black).frame(width: 18, height: 18).offset(x: 2, y: 2)
        }
    }
}

struct Goat: View {
    var body: some View {
        ZStack {
            Horn().stroke(horn, style: StrokeStyle(lineWidth: 26, lineCap: .round))
                .frame(width: 90, height: 150).offset(x: 48, y: -150)
            Horn(flip: true).stroke(horn, style: StrokeStyle(lineWidth: 26, lineCap: .round))
                .frame(width: 90, height: 150).offset(x: -48, y: -150)
            Ellipse().fill(tanDark).frame(width: 110, height: 44).rotationEffect(.degrees(-20)).offset(x: -110, y: -50)
            Ellipse().fill(tanDark).frame(width: 110, height: 44).rotationEffect(.degrees(20)).offset(x: 110, y: -50)
            Capsule().fill(tan).frame(width: 170, height: 280)
            Ellipse().fill(tanDark.opacity(0.5)).frame(width: 120, height: 80).offset(y: 95)
            Eye().offset(x: -42, y: -40)
            Eye().offset(x: 42, y: -40)
            Capsule().fill(.black.opacity(0.6)).frame(width: 12, height: 22).offset(x: -22, y: 90)
            Capsule().fill(.black.opacity(0.6)).frame(width: 12, height: 22).offset(x: 22, y: 90)
            Path { p in
                p.move(to: CGPoint(x: 0, y: 0)); p.addLine(to: CGPoint(x: 60, y: 0)); p.addLine(to: CGPoint(x: 30, y: 80)); p.closeSubpath()
            }
            .fill(wool).frame(width: 60, height: 80).offset(y: 170)
        }
    }
}

struct Sheep: View {
    var body: some View {
        let puffs: [(CGFloat, CGFloat, CGFloat)] = [
            (-95, -60, 110), (0, -105, 120), (95, -60, 110), (-120, 30, 100), (120, 30, 100),
            (-60, -110, 100), (60, -110, 100),
        ]
        ZStack {
            ForEach(Array(puffs.enumerated()), id: \.offset) { _, p in
                Circle().fill(woolShade).frame(width: p.2 + 12, height: p.2 + 12).offset(x: p.0, y: p.1 + 6)
            }
            ForEach(Array(puffs.enumerated()), id: \.offset) { _, p in
                Circle().fill(wool).frame(width: p.2, height: p.2).offset(x: p.0, y: p.1)
            }
            Ellipse().fill(sheepFace).frame(width: 100, height: 40).rotationEffect(.degrees(-25)).offset(x: -110, y: -10)
            Ellipse().fill(sheepFace).frame(width: 100, height: 40).rotationEffect(.degrees(25)).offset(x: 110, y: -10)
            Ellipse().fill(sheepFace).frame(width: 160, height: 220).offset(y: 40)
            ForEach([-60, 0, 60] as [CGFloat], id: \.self) { x in
                Circle().fill(wool).frame(width: 80, height: 80).offset(x: x, y: -55)
            }
            Eye().offset(x: -36, y: 20)
            Eye().offset(x: 36, y: 20)
            Capsule().fill(.black.opacity(0.7)).frame(width: 40, height: 10).offset(y: 110)
        }
    }
}

struct Icon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 185, style: .continuous)
                .fill(LinearGradient(colors: [Color(red: 0.55, green: 0.80, blue: 0.96), Color(red: 0.80, green: 0.92, blue: 0.99)],
                                     startPoint: .top, endPoint: .bottom))
                .overlay(alignment: .bottom) {
                    Ellipse().fill(Color(red: 0.45, green: 0.72, blue: 0.36)).frame(width: 1300, height: 520).offset(y: 330)
                }
                .clipShape(RoundedRectangle(cornerRadius: 185, style: .continuous))
                .overlay { RoundedRectangle(cornerRadius: 185, style: .continuous).strokeBorder(.white.opacity(0.25), lineWidth: 4) }
                .frame(width: 824, height: 824)
                .shadow(color: .black.opacity(0.3), radius: 12, y: 10)
            Goat().scaleEffect(1.1).offset(x: -180, y: 110)
            Sheep().scaleEffect(1.1).offset(x: 180, y: 130)
        }
        .frame(width: 1024, height: 1024)
    }
}

MainActor.assumeIsolated {
    let out = CommandLine.arguments.dropFirst().first ?? "Resources/Icon.png"
    let renderer = ImageRenderer(content: Icon())
    renderer.scale = 1
    guard let cg = renderer.cgImage else { fatalError("render failed") }
    let rep = NSBitmapImageRep(cgImage: cg)
    try? FileManager.default.createDirectory(at: URL(fileURLWithPath: out).deletingLastPathComponent(), withIntermediateDirectories: true)
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
    print("wrote \(out)")
}
