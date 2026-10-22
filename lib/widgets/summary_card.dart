import 'package:flutter/material.dart';

import 'wave_painter.dart';

class SummaryCard extends StatelessWidget {
  final Widget child;
  const SummaryCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [
                    Color(0xFF2B5BD7),
                    Color(0xFF16397E),
                    Color(0xFF0E2350),
                  ]
                : const [
                    Color(0xFF4A3B44),
                    Color(0xFF30262D),
                    Color(0xFF211A1F),
                  ],
            stops: const [0, .55, 1],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 80,
              child: CustomPaint(
                painter: WavePainter(
                  color: Colors.white,
                  waves: [Wave(.45, .375, .10), Wave(.675, .35, .14)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.white),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
