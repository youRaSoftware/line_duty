/// Значок внутри фигуры и на воротах — второй канал различения цвета
/// (дальтонизм, спека «Палитра»).
enum LaneGlyph { circle, square, triangle, diamond }

/// Четыре потока: цвет фигуры, её линии и ворот. Сами цвета — в core_ui
/// (`AppColors.lane`), домен знает только идентичность и значок.
enum LaneColor {
  red(LaneGlyph.circle),
  amber(LaneGlyph.square),
  green(LaneGlyph.triangle),
  blue(LaneGlyph.diamond);

  final LaneGlyph glyph;

  const LaneColor(this.glyph);
}
