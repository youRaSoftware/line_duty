// Google Play feature graphic 1024×500: фон Метро, сетка точек, скруглённая
// иконка слева, «LINE DUTY» (Unbounded 700) и подзаголовок (Golos Text 500)
// справа, четыре цветные линии-маршрута как декор. PNG без альфы.
//   swift script/make_feature_graphic.swift store/icon_rounded_1024.png store/play_feature_graphic_1024x500.png
import CoreGraphics
import CoreText
import Foundation
import ImageIO

let args = CommandLine.arguments
guard args.count == 3 else { print("usage: make_feature_graphic.swift <icon.png> <out.png>"); exit(1) }
guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: args[1]) as CFURL, nil),
      let icon = CGImageSourceCreateImageAtIndex(src, 0, nil) else { print("cannot load icon"); exit(1) }
for f in ["Unbounded[wght].ttf", "GolosText[wght].ttf"] {
  CTFontManagerRegisterFontsForURL(URL(fileURLWithPath: "core/resources/fonts/\(f)") as CFURL, .process, nil)
}

let w = 1024, h = 500
let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!,
                    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
func color(_ v: UInt32, _ a: CGFloat = 1) -> CGColor {
  CGColor(srgbRed: CGFloat((v >> 16) & 0xFF) / 255, green: CGFloat((v >> 8) & 0xFF) / 255,
          blue: CGFloat(v & 0xFF) / 255, alpha: a)
}
ctx.setFillColor(color(0x0D131E)); ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
ctx.setFillColor(color(0x1B2635))
for x in stride(from: 16, to: w, by: 24) { for y in stride(from: 12, to: h, by: 24) {
  ctx.fillEllipse(in: CGRect(x: x, y: y, width: 3, height: 3)) } }
// Линии-маршруты (декор справа, полупрозрачные)
let lanes: [UInt32] = [0xE8503A, 0xF2B233, 0x2EB872, 0x3E8BE8]
ctx.setLineWidth(6); ctx.setLineCap(.round); ctx.setLineJoin(.round)
for (i, c) in lanes.enumerated() {
  let x0 = CGFloat(560 + i * 118)
  ctx.setStrokeColor(color(c, 0.35))
  ctx.move(to: CGPoint(x: x0, y: 510)); ctx.addLine(to: CGPoint(x: x0 + 30, y: 430))
  ctx.addLine(to: CGPoint(x: x0 - 40, y: 350)); ctx.addLine(to: CGPoint(x: x0 + 10, y: 300))
  ctx.strokePath()
}
// Иконка
let iconSize: CGFloat = 340
ctx.interpolationQuality = .high
ctx.draw(icon, in: CGRect(x: 96, y: (CGFloat(h) - iconSize) / 2, width: iconSize, height: iconSize))
// Текст
func font(_ name: String, _ size: CGFloat, _ weight: Double) -> CTFont {
  let wght = 0x77676874 as Int  // 'wght'
  let desc = CTFontDescriptorCreateWithAttributes([
    kCTFontNameAttribute: name as CFString,
    kCTFontVariationAttribute: [NSNumber(value: wght): NSNumber(value: weight)] as CFDictionary,
  ] as CFDictionary)
  return CTFontCreateWithFontDescriptor(desc, size, nil)
}
func draw(_ text: String, _ f: CTFont, _ c: UInt32, x: CGFloat, y: CGFloat, kern: CGFloat) {
  let attrs: [CFString: Any] = [kCTFontAttributeName: f, kCTForegroundColorAttributeName: color(c),
                                kCTKernAttributeName: kern as CFNumber]
  let line = CTLineCreateWithAttributedString(CFAttributedStringCreate(nil, text as CFString, attrs as CFDictionary))
  ctx.textPosition = CGPoint(x: x, y: y); CTLineDraw(line, ctx)
}
let title = font("Unbounded", 78, 700)
draw("LINE", title, 0xE8EDF4, x: 488, y: 272, kern: 6)
draw("DUTY", title, 0xE8EDF4, x: 488, y: 178, kern: 6)
draw("DRAW ROUTES · KEEP THEM APART", font("Golos Text", 23, 500), 0x7E93B0, x: 490, y: 122, kern: 4)
// Синий бейдж с ромбом у названия (как в меню)
let badge = CGRect(x: 440, y: 318, width: 36, height: 36)
ctx.setFillColor(color(0x3E8BE8)); ctx.addPath(CGPath(roundedRect: badge, cornerWidth: 9, cornerHeight: 9, transform: nil)); ctx.fillPath()
ctx.setStrokeColor(color(0xE8EDF4)); ctx.setLineWidth(2.5)
ctx.move(to: CGPoint(x: 458, y: 345)); ctx.addLine(to: CGPoint(x: 467, y: 336))
ctx.addLine(to: CGPoint(x: 458, y: 327)); ctx.addLine(to: CGPoint(x: 449, y: 336)); ctx.closePath(); ctx.strokePath()

let out = ctx.makeImage()!
let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: args[2]) as CFURL, "public.png" as CFString, 1, nil)!
CGImageDestinationAddImage(dest, out, nil)
guard CGImageDestinationFinalize(dest) else { print("write failed"); exit(1) }
print("ok \(out.width)x\(out.height)")
