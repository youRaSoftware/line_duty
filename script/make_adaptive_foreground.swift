// Adaptive-icon helper: draws the app icon scaled to 70 % in the centre of a
// transparent 1024×1024 canvas (Android keeps the outer 17 % as safe zone).
//   swift make_adaptive_foreground.swift <icon1024.png> <out.png>
import AppKit
import Foundation

let args = CommandLine.arguments
guard args.count == 3 else { print("usage: make_adaptive_foreground.swift <icon.png> <out.png>"); exit(1) }

func loadImage(_ path: String) -> CGImage {
    let url = URL(fileURLWithPath: path)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { print("cannot load \(path)"); exit(1) }
    return image
}

let icon = loadImage(args[1])
let size = 1024
let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.interpolationQuality = .high
let side = CGFloat(size) * 0.7
let origin = (CGFloat(size) - side) / 2
let rect = CGRect(x: origin, y: origin, width: side, height: side)
let path = CGPath(roundedRect: rect, cornerWidth: side * 0.2237, cornerHeight: side * 0.2237, transform: nil)
ctx.addPath(path)
ctx.clip()
ctx.draw(icon, in: rect)
let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))
print("done")
