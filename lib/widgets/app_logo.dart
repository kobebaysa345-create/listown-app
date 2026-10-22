import 'package:flutter/material.dart';

/// App icon: charcoal rounded square with a yellow coin and an "L".
class LogoPainter extends CustomPainter {
  const LogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100);
    const box = Rect.fromLTWH(0, 0, 100, 100);
    final rrect = RRect.fromRectAndRadius(box, const Radius.circular(28));
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A3B44), Color(0xFF30262D)],
        ).createShader(box),
    );
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawPath(
      Path()
        ..moveTo(0, 78)
        ..quadraticBezierTo(25, 66, 50, 78)
        ..quadraticBezierTo(75, 90, 100, 78)
        ..lineTo(100, 100)
        ..lineTo(0, 100)
        ..close(),
      Paint()..color = const Color(0xFFF8FF4F).withAlpha(60),
    );
    canvas.restore();
    canvas.drawCircle(
      const Offset(50, 46),
      27,
      Paint()..color = const Color(0xFFF8FF4F),
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: 'L',
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: Color(0xFF30262D),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final base = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    tp.paint(canvas, Offset(50 - tp.width / 2, 57 - base));
    canvas.restore();
  }

  @override
  bool shouldRepaint(LogoPainter old) => false;
}

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo(this.size, {super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: const CustomPaint(painter: LogoPainter()),
  );
}
