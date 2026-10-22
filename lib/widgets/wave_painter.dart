import 'package:flutter/material.dart';

import '../theme/palette.dart';

class Wave {
  final double base, amp, opacity; // fractions of the paint height
  const Wave(this.base, this.amp, this.opacity);
}

class WavePainter extends CustomPainter {
  final Color color;
  final List<Wave> waves;
  const WavePainter({required this.color, required this.waves});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    for (final wv in waves) {
      final y = wv.base * h, a = wv.amp * h;
      final path = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(w * .25, y - a, w * .5, y)
        ..quadraticBezierTo(w * .75, y + a, w, y)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(path, Paint()..color = fade(color, wv.opacity));
    }
  }

  @override
  bool shouldRepaint(WavePainter old) => old.color != color;
}
