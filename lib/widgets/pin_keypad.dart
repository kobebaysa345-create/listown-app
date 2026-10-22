import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/palette.dart';

class PinDots extends StatelessWidget {
  final int filled;
  final bool error;
  const PinDots({super.key, required this.filled, this.error = false});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final col = error ? p.red : p.on;
    return Semantics(
      label: 'PIN, $filled of 4 digits entered',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 4; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < filled ? col : Colors.transparent,
                  border: Border.all(color: col, width: 2.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PinKeypad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBack;
  final bool enabled;
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBack,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);

    Widget key(Widget child, String label, VoidCallback tap) => Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: 76,
        height: 76,
        child: Material(
          color: p.chip,
          shape: CircleBorder(side: BorderSide(color: p.line)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled
                ? () {
                    HapticFeedback.selectionClick();
                    tap();
                  }
                : null,
            child: Center(child: child),
          ),
        ),
      ),
    );

    Widget digit(String d) => key(
      ExcludeSemantics(
        child: Text(
          d,
          style: TextStyle(
            color: p.on,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      d,
      () => onDigit(d),
    );

    Widget row(List<Widget> c) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: c,
      ),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          row([digit('1'), digit('2'), digit('3')]),
          row([digit('4'), digit('5'), digit('6')]),
          row([digit('7'), digit('8'), digit('9')]),
          row([
            const SizedBox(width: 76, height: 76),
            digit('0'),
            key(Icon(Icons.backspace_outlined, color: p.on), 'Delete', onBack),
          ]),
        ],
      ),
    );
  }
}

/// Header + dots + keypad used by both PIN screens.
class PinPanel extends StatelessWidget {
  final String title, subtitle;
  final int filled;
  final String? error;
  final Animation<double> shake;
  final bool enabled;
  final void Function(String) onDigit;
  final VoidCallback onBack;
  final Widget? footer;
  const PinPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.filled,
    required this.error,
    required this.shake,
    required this.enabled,
    required this.onDigit,
    required this.onBack,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: p.pri, shape: BoxShape.circle),
              child: Icon(Icons.lock_rounded, color: p.onPri, size: 30),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.on,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.mut, fontSize: 14.5),
            ),
            const SizedBox(height: 26),
            AnimatedBuilder(
              animation: shake,
              builder: (_, ch) => Transform.translate(
                offset: Offset(
                  math.sin(shake.value * math.pi * 6) * 12 * (1 - shake.value),
                  0,
                ),
                child: ch,
              ),
              child: PinDots(filled: filled, error: error != null),
            ),
            SizedBox(
              height: 44,
              child: Center(
                child: error == null
                    ? null
                    : Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: p.red,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            PinKeypad(onDigit: onDigit, onBack: onBack, enabled: enabled),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}
