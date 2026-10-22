import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Large, bold, uppercase wordmark.
class Wordmark extends StatelessWidget {
  final double size;
  final Color? color;
  const Wordmark({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Semantics(
      header: true,
      label: 'LISTOWN',
      child: ExcludeSemantics(
        child: Text(
          'LISTOWN',
          style: TextStyle(
            color: color ?? p.on,
            fontSize: size,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
            height: 1,
          ),
        ),
      ),
    );
  }
}
