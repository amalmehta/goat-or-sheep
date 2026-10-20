// A small lossless PNG writer for the screenshots. ImageIO's PNG encoder doesn't pick a filter per
// row, which leaves the website's sky gradient about twice as big as it needs to be. This one
// converts to sRGB, drops the alpha channel (screenshots are opaque), tries all five PNG row
// filters and keeps the one that should compress best.
import CoreGraphics
import Foundation

enum PNG {
    static func write(_ image: CGImage, to path: String) {
        let width = image.width, height = image.height
        var rgbx = [UInt8](repeating: 0, count: width * height * 4)
        rgbx.withUnsafeMutableBytes { buf in
            let context = CGContext(data: buf.baseAddress, width: width, height: height, bitsPerComponent: 8,
                                    bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        }

        let stride = width * 3
        var filtered = [UInt8](repeating: 0, count: (stride + 1) * height)
        var candidates = [UInt8](repeating: 0, count: 5 * stride)  // None, Sub, Up, Average, Paeth
        rgbx.withUnsafeBufferPointer { pixels in
            filtered.withUnsafeMutableBufferPointer { out in
                candidates.withUnsafeMutableBufferPointer { cand in
                    // PNG filters work on bytes of the row above and the pixel to the left (3 bytes back).
                    func sample(_ x: Int, _ y: Int) -> Int {
                        y < 0 || x < 0 ? 0 : Int(pixels[(y * width + x / 3) * 4 + x % 3])
                    }
                    for y in 0..<height {
                        var costs = (0, 0, 0, 0, 0)
                        for i in 0..<stride {
                            let v = sample(i, y), a = sample(i - 3, y), b = sample(i, y - 1), c = sample(i - 3, y - 1)
                            let p = a + b - c, pa = abs(p - a), pb = abs(p - b), pc = abs(p - c)
                            let paeth = pa <= pb && pa <= pc ? a : (pb <= pc ? b : c)
                            let bytes = (UInt8(truncatingIfNeeded: v), UInt8(truncatingIfNeeded: v - a),
                                         UInt8(truncatingIfNeeded: v - b), UInt8(truncatingIfNeeded: v - (a + b) / 2),
                                         UInt8(truncatingIfNeeded: v - paeth))
                            cand[i] = bytes.0; cand[stride + i] = bytes.1; cand[2 * stride + i] = bytes.2
                            cand[3 * stride + i] = bytes.3; cand[4 * stride + i] = bytes.4
                            costs.0 += Int(Int8(bitPattern: bytes.0).magnitude)
                            costs.1 += Int(Int8(bitPattern: bytes.1).magnitude)
                            costs.2 += Int(Int8(bitPattern: bytes.2).magnitude)
                            costs.3 += Int(Int8(bitPattern: bytes.3).magnitude)
                            costs.4 += Int(Int8(bitPattern: bytes.4).magnitude)
                        }
                        let all = [costs.0, costs.1, costs.2, costs.3, costs.4]
                        let best = all.indices.min { all[$0] < all[$1] }!
                        let start = y * (stride + 1)
                        out[start] = UInt8(best)
                        for i in 0..<stride { out[start + 1 + i] = cand[best * stride + i] }
                    }
                }
            }
        }

        // NSData's .zlib is raw DEFLATE; PNG wants the zlib wrapper around it.
        var zlib: [UInt8] = [0x78, 0x9C]
        zlib += [UInt8](try! (Data(filtered) as NSData).compressed(using: .zlib) as Data)
        zlib += bigEndian(adler32(filtered))

        var png: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        func chunk(_ type: String, _ body: [UInt8]) {
            let typeAndBody = Array(type.utf8) + body
            png += bigEndian(UInt32(body.count)) + typeAndBody + bigEndian(crc32(typeAndBody))
        }
        chunk("IHDR", bigEndian(UInt32(width)) + bigEndian(UInt32(height)) + [8, 2, 0, 0, 0])  // 8-bit RGB
        chunk("sRGB", [0])
        chunk("IDAT", zlib)
        chunk("IEND", [])
        try! Data(png).write(to: URL(fileURLWithPath: path))
    }

    private static func bigEndian(_ v: UInt32) -> [UInt8] {
        [UInt8(v >> 24), UInt8(v >> 16 & 0xFF), UInt8(v >> 8 & 0xFF), UInt8(v & 0xFF)]
    }

    private static func adler32(_ bytes: [UInt8]) -> UInt32 {
        var a: UInt32 = 1, b: UInt32 = 0
        for byte in bytes { a = (a + UInt32(byte)) % 65521; b = (b + a) % 65521 }
        return b << 16 | a
    }

    private static let crcTable: [UInt32] = (0..<256).map { n in
        var c = UInt32(n)
        for _ in 0..<8 { c = c & 1 != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1 }
        return c
    }

    private static func crc32(_ bytes: [UInt8]) -> UInt32 {
        var c: UInt32 = 0xFFFFFFFF
        for byte in bytes { c = crcTable[Int((c ^ UInt32(byte)) & 0xFF)] ^ (c >> 8) }
        return c ^ 0xFFFFFFFF
    }
}
