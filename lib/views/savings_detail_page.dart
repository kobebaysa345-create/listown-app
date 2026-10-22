import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/savings_challenge.dart';
import '../providers/app_controller.dart';
import '../theme/palette.dart';
import '../utils/date_helpers.dart';
import '../utils/formatters.dart';
import '../utils/navigation.dart';
import '../widgets/app_bars.dart';
import '../widgets/dialogs.dart';
import '../widgets/primary_button.dart';
import '../widgets/savings_widgets.dart';
import 'savings_form_page.dart';

class SavingsDetailPage extends ConsumerWidget {
  final int id;
  const SavingsDetailPage({super.key, required this.id});

  Future<void> _addSavings(
    BuildContext context,
    WidgetRef ref,
    SavingsChallenge c,
  ) async {
    final ctrl = ref.read(appControllerProvider.notifier);
    final r = await showDialog<String>(
      context: context,
      builder: (_) => InputDialog(
        title: 'Add savings',
        initial: c.remaining > 0
            ? plainAmount(double.parse(c.perPeriod.toStringAsFixed(2)))
            : '',
        helper:
            'In ${c.currency.code}. Suggested: ${c.currency.sym}${fmt(c.perPeriod)} per ${c.freq.unit}',
      ),
    );
    if (r == null) return;
    final x = parseAmount(r);
    if (x != null && x > 0) ctrl.addSavings(c.id, x);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    SavingsChallenge c,
  ) async {
    final ctrl = ref.read(appControllerProvider.notifier);
    final ok = await confirmDialog(
      context,
      'Delete challenge?',
      '“${c.name}” and its saved progress will be removed.',
      'Delete',
    );
    if (ok && context.mounted) {
      Navigator.pop(context);
      ctrl.removeChallenge(c.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Palette.of(context);
    final c = ref.watch(appControllerProvider.select((s) => s.challengeById(id)));
    if (c == null) {
      return Scaffold(appBar: pageBar(context, 'Savings Challenge'));
    }

    final String title, amount, unit, sub;
    if (c.done) {
      title = 'Goal reached 🎉';
      amount = '${c.currency.sym}${fmt(c.saved)}';
      unit = '';
      sub = 'You saved your goal of ${c.currency.sym}${fmt(c.goal)}';
    } else if (c.pastDue) {
      title = 'Deadline reached';
      amount = '${c.currency.sym}${fmt(c.remaining)}';
      unit = '';
      sub = 'still needed to reach ${c.currency.sym}${fmt(c.goal)}';
    } else {
      title = 'Save';
      amount = '${c.currency.sym}${fmt(c.perPeriod)}';
      unit = c.freq.unit;
      sub = 'to reach ${c.currency.sym}${fmt(c.goal)}';
    }

    Widget info(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: p.mut, fontSize: 15)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: p.on,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Challenge'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: p.on),
            color: p.surface,
            onSelected: (v) {
              if (v == 'edit') {
                go(context, SavingsFormPage(editId: c.id));
              } else {
                _delete(context, ref, c);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit', style: TextStyle(color: p.on)),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: p.red)),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ChallengeAvatar(c.name, size: 60),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: TextStyle(
                                color: p.on,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            savingsProgressBar(p, c.progress),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${c.currency.sym}${fmt(c.saved)}',
                                  style: TextStyle(
                                    color: p.on,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${c.currency.sym}${fmt(c.goal)}',
                                  style: TextStyle(
                                    color: p.on,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const SizedBox(width: 74),
                      info('Finish By', prettyDate(c.finish)),
                      info('Frequency', c.freq.label),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: p.line, height: 1),
                  const SizedBox(height: 16),
                  SavePlanCard(
                    title: title,
                    amount: amount,
                    unit: unit,
                    sub: sub,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: PrimaryButton(
                label: 'Add Savings Now',
                onPressed: () => _addSavings(context, ref, c),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
