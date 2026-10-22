import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/currency.dart';
import '../providers/app_controller.dart';
import '../theme/palette.dart';
import '../utils/formatters.dart';
import 'summary_card.dart';

Future<bool> confirmDialog(
  BuildContext c,
  String title,
  String msg,
  String ok,
) async {
  final p = Palette.of(c);
  final dark = Theme.of(c).brightness == Brightness.dark;
  final r = await showDialog<bool>(
    context: c,
    builder: (ctx) => AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        title,
        style: TextStyle(color: p.on, fontWeight: FontWeight.w400),
      ),
      content: Text(msg, style: TextStyle(color: p.mut)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: p.red,
            foregroundColor: dark ? const Color(0xFF690005) : Colors.white,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(ok),
        ),
      ],
    ),
  );
  return r == true;
}

class InputDialog extends StatefulWidget {
  final String title, initial, helper;
  const InputDialog({
    super.key,
    required this.title,
    required this.initial,
    required this.helper,
  });

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  late final TextEditingController c = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        widget.title,
        style: TextStyle(color: p.on, fontWeight: FontWeight.w400),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: c,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: p.on),
            decoration: InputDecoration(
              filled: true,
              fillColor: p.chip,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              widget.helper,
              style: TextStyle(fontSize: 12, color: p.mut),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, c.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

Future<void> editRate(BuildContext c, WidgetRef ref) async {
  final ctrl = ref.read(appControllerProvider.notifier);
  final s = ref.read(appControllerProvider);
  final r = await showDialog<String>(
    context: c,
    builder: (_) => InputDialog(
      title: 'Exchange rate',
      initial: s.rate.toString(),
      helper: "1 USD = ? PHP. Check a bank or currency site for today's rate",
    ),
  );
  if (r == null) return;
  final x = parseAmount(r);
  if (x != null && x > 0) ctrl.setRate(x);
}

Future<void> editBudget(BuildContext c, WidgetRef ref) async {
  final ctrl = ref.read(appControllerProvider.notifier);
  final s = ref.read(appControllerProvider);
  final r = await showDialog<String>(
    context: c,
    builder: (_) => InputDialog(
      title: 'Monthly budget',
      initial: s.budgetUsd > 0 ? s.budD.toStringAsFixed(2) : '',
      helper: 'In ${s.disp.code}. Set 0 to disable',
    ),
  );
  if (r == null) return;
  if (r.trim().isEmpty) {
    ctrl.setBudgetFromDisplay(0);
    return;
  }
  final x = parseAmount(r);
  if (x != null) ctrl.setBudgetFromDisplay(x);
}

class ConverterDialog extends ConsumerStatefulWidget {
  final Cur from;
  const ConverterDialog({super.key, required this.from});

  @override
  ConsumerState<ConverterDialog> createState() => _ConverterDialogState();
}

class _ConverterDialogState extends ConsumerState<ConverterDialog> {
  late Cur from = widget.from;
  final TextEditingController c = TextEditingController(text: '100');

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  void swap() {
    final s = ref.read(appControllerProvider);
    final n = parseAmount(c.text);
    setState(() {
      c.text = n == null
          ? '100'
          : s.conv(n, from, from.other).toStringAsFixed(2);
      from = from.other;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final s = ref.watch(appControllerProvider);
    final n = parseAmount(c.text);
    final out = n == null
        ? '—'
        : s.moneyIn(s.conv(n, from, from.other), from.other);
    return AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'Currency converter',
        style: TextStyle(color: p.on, fontWeight: FontWeight.w400),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: c,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: p.on),
              decoration: InputDecoration(
                filled: true,
                fillColor: p.chip,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Amount in ${from.code} (${from.sym})',
                style: TextStyle(fontSize: 13, color: p.mut),
              ),
            ),
            SummaryCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(from.other.code, style: const TextStyle(fontSize: 13)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      out,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '1 USD = ${fmt(s.rate)} PHP',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: swap, child: const Text('⇅ Swap')),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

void showConverter(BuildContext c, Cur from) => showDialog<void>(
  context: c,
  builder: (_) => ConverterDialog(from: from),
);

void showLegal(BuildContext context, String title, String body) {
  final p = Palette.of(context);
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title, style: TextStyle(color: p.on)),
      content: SingleChildScrollView(
        child: Text(body, style: TextStyle(color: p.mut, height: 1.4)),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

void showHelpSheet(BuildContext context) {
  final p = Palette.of(context);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How LISTOWN works',
              style: TextStyle(
                color: p.on,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            for (final t in const [
              '1. Create a profile with your name and a 4-digit PIN.',
              '2. Add expenses in PHP or USD and set a monthly budget.',
              '3. Log in with your profile name and PIN. Each profile keeps its own expenses.',
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(t, style: TextStyle(color: p.on, fontSize: 15)),
              ),
          ],
        ),
      ),
    ),
  );
}
