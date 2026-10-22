import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_controller.dart';
import '../theme/palette.dart';

/// "⇄ USD" chip that flips the display currency.
class CurrencyToggleChip extends ConsumerWidget {
  const CurrencyToggleChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Palette.of(context);
    final disp = ref.watch(appControllerProvider.select((s) => s.disp));
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ActionChip(
        label: Text('⇄ ${disp.code}'),
        onPressed: () => ref.read(appControllerProvider.notifier).toggleDisp(),
        backgroundColor: Colors.transparent,
        labelStyle: TextStyle(color: p.on, fontSize: 13),
        side: BorderSide(color: p.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

AppBar pageBar(BuildContext c, String title) =>
    AppBar(title: Text(title), actions: const [CurrencyToggleChip()]);

class AddExpenseFab extends StatelessWidget {
  final VoidCallback onPressed;
  const AddExpenseFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: p.pri,
      foregroundColor: p.onPri,
      icon: const Icon(Icons.add),
      label: const Text(
        'Add expense',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}
