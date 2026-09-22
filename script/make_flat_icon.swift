// Flattens a rounded/transparent icon onto a solid background (App Store
// icons must have no alpha channel).
//   swift make_flat_icon.swift <icon.png> <out.png> <RRGGBB>
import AppKit
import Foundation

let args = CommandLine.arguments
guard args.count == 4 else { print("usage: make_flat_icon.swift <icon.png> <out.png> <RRGGBB>"); exit(1) }
let url = URL(fileURLWithPath: args[1])
guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
      let icon = CGImageSourceCreateImageAtIndex(source, 0, nil) else { print("cannot load"); exit(1) }
let hex = UInt32(args[3], radix: 16)!
let r = CGFloat((hex >> 16) & 0xFF) / 255, g = CGFloat((hex >> 8) & 0xFF) / 255, b = CGFloat(hex & 0xFF) / 255
let size = icon.width
let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!,
                    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
ctx.setFillColor(CGColor(srgbRed: r, green: g, blue: b, alpha: 1))
ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))
ctx.interpolationQuality = .high
ctx.draw(icon, in: CGRect(x: 0, y: 0, width: size, height: size))
let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))
print("done")
