import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Flat illustration for the onboarding hero. [prop] 0 = grocery bag,
/// 1 = spending chart board. Original artwork, drawn in code.
class HeroArtPainter extends CustomPainter {
  final int prop;
  const HeroArtPainter(this.prop);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final s = math.min(w, h);
    final cx = w * .5;
    Paint f(int c) => Paint()..color = Color(c);

    final skin = f(0xFFF0C4A0), hair = f(0xFF2A1E22);
    final jacket = f(0xFF8FA99A), tee = f(0xFFFFFFFF);

    // Hair (back)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * .42),
          width: s * .38,
          height: s * .46,
        ),
        Radius.circular(s * .19),
      ),
      hair,
    );

    // Body
    final bodyTop = h * .60;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(cx - s * .34, bodyTop, s * .68, h - bodyTop + s),
        topLeft: Radius.circular(s * .2),
        topRight: Radius.circular(s * .2),
      ),
      jacket,
    );
    canvas.drawRect(
      Rect.fromLTWH(cx - s * .09, bodyTop, s * .18, h - bodyTop + s),
      tee,
    );

    // Neck + head
    canvas.drawRect(
      Rect.fromLTWH(cx - s * .05, h * .50, s * .10, bodyTop - h * .50 + 2),
      skin,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * .41),
        width: s * .26,
        height: s * .30,
      ),
      skin,
    );
    // Fringe
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, h * .395),
        width: s * .29,
        height: s * .32,
      ),
      math.pi,
      math.pi,
      true,
      hair,
    );
    // Eyes + smile
    final eye = f(0xFF2A1E22);
    canvas.drawCircle(Offset(cx - s * .045, h * .42), s * .011, eye);
    canvas.drawCircle(Offset(cx + s * .045, h * .42), s * .011, eye);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, h * .445),
        width: s * .09,
        height: s * .06,
      ),
      .15,
      math.pi - .3,
      false,
      Paint()
        ..color = const Color(0xFF9B3B3B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .012
        ..strokeCap = StrokeCap.round,
    );

    // Phone in the left hand
    final phone = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - s * .33, h * .55, s * .10, s * .19),
      Radius.circular(s * .02),
    );
    canvas.drawRRect(phone, f(0xFFE53935));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - s * .322, h * .558, s * .084, s * .174),
        Radius.circular(s * .015),
      ),
      f(0xFF3B2F34),
    );
    canvas.drawCircle(Offset(cx - s * .28, h * .74), s * .032, skin);

    if (prop == 0) {
      // Grocery bag with produce
      final bag = Rect.fromLTWH(cx + s * .06, h * .68, s * .32, h * .5);
      canvas.drawCircle(
        Offset(cx + s * .14, h * .665),
        s * .065,
        f(0xFF3E8E41),
      );
      canvas.drawCircle(Offset(cx + s * .26, h * .67), s * .045, f(0xFFF28C28));
      canvas.drawCircle(Offset(cx + s * .33, h * .655), s * .04, f(0xFFFFC928));
      canvas.drawRRect(
        RRect.fromRectAndRadius(bag, Radius.circular(s * .02)),
        f(0xFFD2B48C),
      );
      canvas.drawRect(
        Rect.fromLTWH(bag.left, bag.top, bag.width, s * .025),
        f(0xFFBF9F72),
      );
      canvas.drawCircle(Offset(cx + s * .08, h * .83), s * .032, skin);
    } else {
      // Spending chart board
      final board = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + s * .05, h * .62, s * .36, s * .27),
        Radius.circular(s * .04),
      );
      canvas.drawRRect(board, f(0xFFFFFFFF));
      const hs = [.35, .6, .45, .85];
      const cs = [0xFF4C9A2A, 0xFFD9541E, 0xFF4C9A2A, 0xFF30262D];
      for (var i = 0; i < 4; i++) {
        final bh = s * .19 * hs[i];
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              cx + s * .09 + i * s * .08,
              h * .62 + s * .23 - bh,
              s * .05,
              bh,
            ),
            Radius.circular(s * .01),
          ),
          f(cs[i]),
        );
      }
      canvas.drawCircle(Offset(cx + s * .07, h * .85), s * .032, skin);
    }
  }

  @override
  bool shouldRepaint(HeroArtPainter old) => old.prop != prop;
}
