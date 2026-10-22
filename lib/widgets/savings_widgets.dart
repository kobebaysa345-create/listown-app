import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Lilac card: "Save ₱88.24 / day to reach ₱1,500.00".
class SavePlanCard extends StatelessWidget {
  final String title, amount, unit, sub;
  const SavePlanCard({
    super.key,
    required this.title,
    required this.amount,
    required this.unit,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(
        color: kLilac,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: amount,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (unit.isNotEmpty)
                        TextSpan(
                          text: ' / $unit',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  style: const TextStyle(color: kInk),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                    color: kInk,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kCoin,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD9A800), width: 3),
            ),
            child: const Text(
              '₱',
              style: TextStyle(
                color: Color(0xFF8A6A00),
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChallengeAvatar extends StatelessWidget {
  final String name;
  final double size;
  const ChallengeAvatar(this.name, {super.key, this.size = 52});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(color: kLilac, shape: BoxShape.circle),
    child: Text(
      name.isEmpty ? '?' : name[0].toUpperCase(),
      style: TextStyle(
        color: kInk,
        fontSize: size * .42,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

Widget savingsProgressBar(Palette p, double v) => ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: LinearProgressIndicator(
    value: v,
    minHeight: 10,
    backgroundColor: fade(p.on, .12),
    valueColor: AlwaysStoppedAnimation(p.pri == p.on ? p.on : p.pri),
  ),
);
