import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/currency.dart';
import '../providers/app_controller.dart';
import '../theme/palette.dart';
import '../utils/formatters.dart';
import '../widgets/app_bars.dart';
import '../widgets/common_widgets.dart';
import '../widgets/dialogs.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Palette.of(context);
    final s = ref.watch(appControllerProvider);
    final ctrl = ref.read(appControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget tile(
      String emoji,
      String title, {
      String? sub,
      VoidCallback? onTap,
      Color? color,
      Widget? trailing,
    }) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(emoji, style: const TextStyle(fontSize: 20)),
      title: Text(title, style: TextStyle(color: color ?? p.on, fontSize: 16)),
      subtitle: sub == null
          ? null
          : Text(sub, style: TextStyle(color: p.mut, fontSize: 13)),
      trailing: trailing,
      onTap: onTap,
    );

    final fullName = '${s.firstName} ${s.lastName}'.trim();

    return Scaffold(
      appBar: pageBar(context, 'Settings'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          sectionHeader(context, 'Account'),
          tile(
            '👤',
            fullName.isEmpty ? 'Guest' : fullName,
            sub: s.profileName.isEmpty ? null : '@${s.profileName}',
          ),
          sectionHeader(context, 'Currency'),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<Cur>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: Cur.usd, label: Text('Dollars')),
                ButtonSegment(value: Cur.php, label: Text('Pesos')),
              ],
              selected: {s.disp},
              onSelectionChanged: (sel) => ctrl.setDisp(sel.first),
              style: SegmentedButton.styleFrom(
                foregroundColor: p.on,
                selectedForegroundColor: p.on,
                selectedBackgroundColor: p.sel,
                side: BorderSide(color: p.line),
              ),
            ),
          ),
          tile(
            '💱',
            'Exchange rate',
            sub: '1 USD = ${fmt(s.rate)} PHP',
            onTap: () => editRate(context, ref),
          ),
          tile(
            '🧮',
            'Currency converter',
            sub: 'Convert between USD and PHP',
            onTap: () => showConverter(context, s.disp),
          ),
          sectionHeader(context, 'Preferences'),
          tile(
            '🐷',
            'Monthly budget',
            sub: s.budgetUsd > 0 ? s.money(s.budD) : 'Not set',
            onTap: () => editBudget(context, ref),
          ),
          tile(
            '🌙',
            'Dark mode',
            onTap: () => ctrl.setDark(!isDark),
            trailing: Switch(value: isDark, onChanged: ctrl.setDark),
          ),
          sectionHeader(context, 'Data'),
          tile(
            '🧾',
            'Total records',
            trailing: Text(
              '${s.items.length}',
              style: TextStyle(
                color: p.on,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          tile(
            '⚠️',
            'Delete all expenses',
            color: p.red,
            onTap: () async {
              final ok = await confirmDialog(
                context,
                'Delete all expenses?',
                'This cannot be undone.',
                'Delete all',
              );
              if (ok) {
                ctrl.clearExpenses();
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('All data cleared')),
                    );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
