import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_state.dart';
import '../models/category.dart';
import '../providers/app_controller.dart';
import '../theme/palette.dart';
import '../utils/date_helpers.dart';
import '../utils/formatters.dart';
import '../utils/navigation.dart';
import '../widgets/app_bars.dart';
import '../widgets/app_logo.dart';
import '../widgets/expense_tile.dart';
import '../widgets/summary_card.dart';
import 'expense_form_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  /// The month being viewed (always the 1st of the month).
  late DateTime month = DateTime(DateTime.now().year, DateTime.now().month);

  void _shift(int delta) =>
      setState(() => month = DateTime(month.year, month.month + delta));

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final s = ref.watch(appControllerProvider);
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final isCurrent = month == thisMonth;
    final earliest = s.earliestMonth;
    final canPrev = earliest != null && month.isAfter(earliest);
    final canNext = month.isBefore(thisMonth);

    final items = s.monthItemsFor(month);
    final total = items.fold<double>(0, (sum, e) => sum + s.inD(e));
    final b = s.budD;
    final over = b > 0 && total > b;
    final by = <String, double>{};
    for (final e in items) {
      by[e.category] = (by[e.category] ?? 0) + s.inD(e);
    }
    final entries = by.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final pct = b > 0 ? (total / b).clamp(0.0, 1.0).toDouble() : 0.0;
    final recent = s.sorted
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .take(5)
        .toList();
    final monthName = monthNames[month.month - 1];

    return Scaffold(
      appBar: pageBar(context, 'Dashboard'),
      floatingActionButton: AddExpenseFab(
        onPressed: () => go(context, const ExpenseFormPage()),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        children: [
          SummaryCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AppLogo(28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$monthName ${month.year}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Previous month',
                      visualDensity: VisualDensity.compact,
                      color: Colors.white,
                      disabledColor: Colors.white30,
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: canPrev ? () => _shift(-1) : null,
                    ),
                    IconButton(
                      tooltip: 'Next month',
                      visualDensity: VisualDensity.compact,
                      color: Colors.white,
                      disabledColor: Colors.white30,
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: canNext ? () => _shift(1) : null,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Opacity(
                  opacity: .8,
                  child: Text(
                    isCurrent ? 'Spent this month' : 'Spent in $monthName',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 2),
                  child: Text(
                    s.money(total),
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '≈ ${s.moneyIn(s.conv(total, s.disp, s.disp.other), s.disp.other)} • 1 USD = ${fmt(s.rate)} PHP',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                if (b > 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 10,
                      backgroundColor: Colors.white.withAlpha(64),
                      valueColor: AlwaysStoppedAnimation(
                        over
                            ? const Color(0xFFFFB4A2)
                            : const Color(0xFFF8FF4F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    over
                        ? 'Over budget by ${s.money(total - b)}'
                        : '${s.money(b - total)} left of ${s.money(b)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: over ? const Color(0xFFFFD2C6) : Colors.white,
                    ),
                  ),
                ] else
                  const Text('No budget set (see Settings)'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 8),
            child: Text(
              'By category',
              style: TextStyle(
                color: p.on,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  isCurrent
                      ? 'No expenses this month yet.'
                      : 'No expenses in $monthName.',
                  style: TextStyle(color: p.mut, fontSize: 14),
                ),
              ),
            )
          else
            for (final en in entries) _categoryRow(p, s, en.key, en.value, total),
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 8),
            child: Text(
              'Recent',
              style: TextStyle(
                color: p.on,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  isCurrent
                      ? 'Tap “Add expense” to get started.'
                      : 'Nothing recorded in $monthName.',
                  style: TextStyle(color: p.mut, fontSize: 14),
                ),
              ),
            )
          else
            for (final e in recent)
              ExpenseTile(
                e,
                onTap: () => go(context, ExpenseFormPage(editId: e.id)),
              ),
        ],
      ),
    );
  }

  Widget _categoryRow(
    Palette p,
    AppStateData s,
    String name,
    double v,
    double total,
  ) {
    final c = catOf(name);
    final share = total > 0 ? v / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              Text(c.emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name, style: TextStyle(color: p.on, fontSize: 14)),
              ),
              Text(
                s.money(v),
                style: TextStyle(
                  color: p.on,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '${(share * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: p.on, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: share,
              minHeight: 6,
              backgroundColor: const Color(0x40808080),
              valueColor: AlwaysStoppedAnimation(c.color),
            ),
          ),
        ],
      ),
    );
  }
}
