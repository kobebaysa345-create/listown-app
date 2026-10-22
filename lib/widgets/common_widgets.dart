import 'package:flutter/material.dart';

import '../theme/palette.dart';

Widget sectionHeader(BuildContext c, String t) {
  final p = Palette.of(c);
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
    child: Text(
      t.toUpperCase(),
      style: TextStyle(
        color: p.on,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    ),
  );
}

/// Shared rounded, filled text-field decoration.
InputDecoration fieldDec(
  Palette p,
  String label, {
  String? error,
  Widget? suffixIcon,
}) {
  OutlineInputBorder b(Color col, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: col, width: w),
  );
  return InputDecoration(
    labelText: label,
    errorText: error,
    filled: true,
    fillColor: p.chip,
    suffixIcon: suffixIcon,
    labelStyle: TextStyle(color: p.mut),
    floatingLabelStyle: TextStyle(color: error != null ? p.red : p.on),
    errorStyle: TextStyle(color: p.red, fontWeight: FontWeight.w500),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: b(p.line),
    enabledBorder: b(p.line),
    focusedBorder: b(p.on, 2),
    errorBorder: b(p.red),
    focusedErrorBorder: b(p.red, 2),
  );
}

/// Fade + slide-up entrance. Skipped when the system disables animations.
class Entrance extends StatelessWidget {
  final Widget child;
  final int ms;
  final double dy;
  const Entrance({super.key, required this.child, this.ms = 550, this.dy = 18});

  @override
  Widget build(BuildContext context) {
    final off = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: off ? 1 : 0, end: 1),
      duration: Duration(milliseconds: off ? 0 : ms),
      curve: Curves.easeOutCubic,
      builder: (_, v, ch) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * dy), child: ch),
      ),
      child: child,
    );
  }
}
