import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/currency.dart';
import '../models/savings_challenge.dart';
import '../providers/app_controller.dart';
import '../theme/palette.dart';
import '../utils/date_helpers.dart';
import '../utils/formatters.dart';
import '../widgets/common_widgets.dart';
import '../widgets/primary_button.dart';
import '../widgets/savings_widgets.dart';

class SavingsFormPage extends ConsumerStatefulWidget {
  final int? editId;
  const SavingsFormPage({super.key, this.editId});

  @override
  ConsumerState<SavingsFormPage> createState() => _SavingsFormPageState();
}

class _SavingsFormPageState extends ConsumerState<SavingsFormPage> {
  late final TextEditingController nameC;
  late final TextEditingController goalC;
  late Freq freq;
  late Cur cur;
  double savedSoFar = 0;
  DateTime? finish;
  String? dateErr;

  bool get editing => widget.editId != null;

  @override
  void initState() {
    super.initState();
    final s = ref.read(appControllerProvider);
    final c = editing ? s.challengeById(widget.editId!) : null;
    nameC = TextEditingController(text: c?.name ?? '');
    goalC = TextEditingController(text: c == null ? '' : plainAmount(c.goal));
    freq = c?.freq ?? Freq.daily;
    cur = c?.currency ?? s.disp;
    finish = c?.finish;
    savedSoFar = c?.saved ?? 0;
  }

  @override
  void dispose() {
    nameC.dispose();
    goalC.dispose();
    super.dispose();
  }

  double? get _goal => parseAmount(goalC.text.trim());

  bool get _valid =>
      nameC.text.trim().isNotEmpty && (_goal ?? 0) > 0 && finish != null;

  Future<void> _pickDate() async {
    final t = today();
    var initial = finish ?? t.add(const Duration(days: 1));
    if (initial.isBefore(t)) initial = t;
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: t,
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() {
        finish = d;
        dateErr = null;
      });
    }
  }

  void _save() {
    final f = finish;
    if (f == null || !_valid) return;
    if (!f.isAfter(today())) {
      setState(() => dateErr = 'Pick a date after today');
      return;
    }
    // Editing keeps the amount already saved: the controller only changes
    // name, goal, currency, frequency and deadline.
    ref
        .read(appControllerProvider.notifier)
        .saveChallenge(
          id: widget.editId,
          name: nameC.text.trim(),
          goal: _goal!,
          currency: cur,
          freq: freq,
          finish: f,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final g = _goal ?? 0;
    final f = finish;
    final ready = g > 0 && f != null && f.isAfter(today());
    final remaining = math.max(g - savedSoFar, 0);
    final per = ready ? remaining / periodsLeft(freq, f) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit Challenge' : 'Savings Challenge'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  TextField(
                    controller: nameC,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [LengthLimitingTextInputFormatter(40)],
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: p.on, fontSize: 16),
                    decoration: fieldDec(p, 'Name *').copyWith(
                      hintText: 'Ex. Thesis Savings',
                      hintStyle: TextStyle(color: p.mut),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: goalC,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: p.on, fontSize: 16),
                    decoration: fieldDec(
                      p,
                      'Goal Amount * (${cur.sym})',
                    ).copyWith(
                      hintText: '0.00',
                      hintStyle: TextStyle(color: p.mut),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Freq>(
                    initialValue: freq,
                    dropdownColor: p.surface,
                    style: TextStyle(color: p.on, fontSize: 16),
                    decoration: fieldDec(p, 'Frequency'),
                    items: [
                      for (final x in Freq.values)
                        DropdownMenuItem(value: x, child: Text(x.label)),
                    ],
                    onChanged: (v) => setState(() => freq = v ?? freq),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: fieldDec(
                        p,
                        'Date to finish *',
                        error: dateErr,
                        suffixIcon: Icon(
                          Icons.calendar_today_outlined,
                          color: p.on,
                          size: 22,
                        ),
                      ),
                      child: Text(
                        f == null ? 'Select date' : ymd(f),
                        style: TextStyle(
                          color: f == null ? p.mut : p.on,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SavePlanCard(
                    title: 'Save',
                    amount: '${cur.sym}${fmt(per)}',
                    unit: freq.unit,
                    sub: 'to reach ${cur.sym}${fmt(g)}',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: PrimaryButton(
                label:
                    editing
                        ? 'Update Savings Challenge'
                        : 'Save Savings Challenge',
                onPressed: _valid ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
