import 'package:flutter/material.dart';

import '../theme/palette.dart';
import 'hero_art_painter.dart';

class Slide {
  final String tag, headline, body;
  final String amountA, labelA, amountB, labelB;
  final int prop;
  const Slide({
    required this.tag,
    required this.headline,
    required this.body,
    required this.amountA,
    required this.labelA,
    required this.amountB,
    required this.labelB,
    required this.prop,
  });
}

// Placeholder sample values only, not real user data.
const onboardingSlides = [
  Slide(
    tag: 'Budgeting',
    headline: 'Take control of your money.',
    body: 'Set a monthly budget, organize your spending, and make every peso count.',
    amountA: '₱4,850',
    labelA: 'Monthly savings',
    amountB: '₱10,800',
    labelB: 'Monthly budget',
    prop: 0,
  ),
  Slide(
    tag: 'Tracking',
    headline: 'Know where it all goes.',
    body: 'Log expenses in PHP or USD and watch your categories add up instantly.',
    amountA: '₱2,340',
    labelA: 'Spent this week',
    amountB: '₱8,460',
    labelB: 'Left this month',
    prop: 1,
  ),
];

/// Rounded pill with a colored end segment, like a floating info card.
class InfoPill extends StatelessWidget {
  final String amount, label;
  final Color bg, accent;
  final bool accentLeft;
  const InfoPill({
    super.key,
    required this.amount,
    required this.label,
    required this.bg,
    required this.accent,
    this.accentLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    final seg = Container(width: 26, color: accent);
    return Semantics(
      label: '$label $amount',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (accentLeft) seg,
                  Container(
                    color: bg,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          amount,
                          style: const TextStyle(
                            color: kInk,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          label,
                          style: const TextStyle(color: kInk, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  if (!accentLeft) seg,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One hero page: label tab on top, illustration panel with floating cards.
class HeroPage extends StatelessWidget {
  final Slide slide;
  const HeroPage({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.pri,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Text(
            slide.tag,
            style: TextStyle(
              color: p.onPri,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(22),
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(22),
            ),
            child: Container(
              color: p.hero,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: HeroArtPainter(slide.prop)),
                  ),
                  Align(
                    alignment: const Alignment(1, -.35),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InfoPill(
                        amount: slide.amountA,
                        label: slide.labelA,
                        bg: kLime,
                        accent: kGreen,
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(-1, .72),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: InfoPill(
                        amount: slide.amountB,
                        label: slide.labelB,
                        bg: kPink,
                        accent: kCoral,
                        accentLeft: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PageDots extends StatelessWidget {
  final int count, index;
  final ValueChanged<int> onTap;
  const PageDots({
    super.key,
    required this.count,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(i),
            child: Semantics(
              button: true,
              label: 'Page ${i + 1} of $count',
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: i == index ? 34 : 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: i == index ? p.on : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: p.on, width: 2),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
