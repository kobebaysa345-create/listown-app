import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/expense.dart';
import '../providers/app_controller.dart';
import '../theme/palette.dart';
import '../utils/date_helpers.dart';

class ExpenseTile extends ConsumerWidget {
  final Expense e;
  final VoidCallback onTap;
  const ExpenseTile(this.e, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Palette.of(context);
    final s = ref.watch(appControllerProvider);
    final c = catOf(e.category);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fade(c.color, .15),
                shape: BoxShape.circle,
              ),
              child: Text(c.emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.on,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${c.name} • ${ymd(e.date)}',
                    style: TextStyle(color: p.mut, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  s.money(s.inD(e)),
                  style: TextStyle(color: p.on, fontWeight: FontWeight.w700),
                ),
                if (e.currency != s.disp)
                  Text(
                    'entered ${s.moneyIn(e.amount, e.currency)}',
                    style: TextStyle(color: p.mut, fontSize: 11),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
