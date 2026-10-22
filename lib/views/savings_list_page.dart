import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_controller.dart';
import '../theme/palette.dart';
import '../utils/formatters.dart';
import '../utils/navigation.dart';
import '../widgets/app_bars.dart';
import '../widgets/primary_button.dart';
import '../widgets/savings_widgets.dart';
import 'savings_detail_page.dart';
import 'savings_form_page.dart';

class SavingsListPage extends ConsumerWidget {
  const SavingsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Palette.of(context);
    final list = ref.watch(appControllerProvider.select((s) => s.challenges));
    return Scaffold(
      appBar: pageBar(context, 'Savings Challenge'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.savings_outlined, size: 56, color: p.mut),
                            const SizedBox(height: 12),
                            Text(
                              'No savings challenges yet',
                              style: TextStyle(
                                color: p.on,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Set a goal like “Thesis Savings” and see how much to save each day, week or month.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: p.mut, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        final c = list[i];
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => go(context, SavingsDetailPage(id: c.id)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ChallengeAvatar(c.name),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: p.on,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          '${c.currency.sym}${fmt(c.saved)} / ${c.currency.sym}${fmt(c.goal)}',
                                          style: TextStyle(
                                            color: p.mut,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: p.on,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              savingsProgressBar(p, c.progress),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: PrimaryButton(
                label: 'New Savings Challenge',
                onPressed: () => go(context, const SavingsFormPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
