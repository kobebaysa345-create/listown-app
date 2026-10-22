import 'package:flutter/material.dart';

Color fade(Color c, double o) => c.withAlpha((o * 255).round());

// LIGHT = lemon yellow + charcoal.  DARK = navy blue + yellow accent.
class Palette {
  final Color bg,
      surface,
      card,
      on,
      mut,
      pri,
      onPri,
      line,
      chip,
      red,
      sel,
      hero;
  const Palette({
    required this.bg,
    required this.surface,
    required this.card,
    required this.on,
    required this.mut,
    required this.pri,
    required this.onPri,
    required this.line,
    required this.chip,
    required this.red,
    required this.sel,
    required this.hero,
  });

  static const light = Palette(
    bg: Color(0xFFF8FF4F),
    surface: Color(0xFFF8FF4F),
    card: Color(0xFFFFFFFF),
    on: Color(0xFF30262D),
    mut: Color(0xFF5E5340),
    pri: Color(0xFF30262D),
    onPri: Color(0xFFF8FF4F),
    line: Color(0x4D30262D),
    chip: Color(0xFFFFFFFF),
    red: Color(0xFFB3261E),
    sel: Color(0xFFFFFFFF),
    hero: Color(0xFFB9D9E6),
  );

  static const dark = Palette(
    bg: Color(0xFF081426),
    surface: Color(0xFF0B1B33),
    card: Color(0xFF14294A),
    on: Color(0xFFE8EEFA),
    mut: Color(0xFF9AAAC8),
    pri: Color(0xFFF8FF4F),
    onPri: Color(0xFF0B1B33),
    line: Color(0xFF263B60),
    chip: Color(0xFF14264A),
    red: Color(0xFFFFB4AB),
    sel: Color(0xFF1F3868),
    hero: Color(0xFF16294A),
  );

  static Palette of(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dark : light;
}

// Small accent colors used by the floating info cards (same in both themes).
const kLime = Color(0xFFDDF8A8);
const kGreen = Color(0xFF4C9A2A);
const kPink = Color(0xFFFFBFE6);
const kCoral = Color(0xFFD9541E);
const kInk = Color(0xFF30262D);
const kLilac = Color(0xFFE9D8FA); // savings challenge accents
const kCoin = Color(0xFFF5C518);
