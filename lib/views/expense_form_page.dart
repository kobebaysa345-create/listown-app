import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/currency.dart';
import '../providers/app_controller.dart';
import '../theme/palette.dart';
import '../utils/date_helpers.dart';
import '../utils/formatters.dart';
import '../widgets/common_widgets.dart';
import '../widgets/dialogs.dart';
import '../widgets/primary_button.dart';

class ExpenseFormPage extends ConsumerStatefulWidget {
  final int? editId;
  const ExpenseFormPage({super.key, this.editId});

  @override
  ConsumerState<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends ConsumerState<ExpenseFormPage> {
  late final TextEditingController titleC;
  late final TextEditingController amountC;
  late final TextEditingController noteC;
  late Cur cur;
  late String category;
  late DateTime date;
  String? titleErr, amountErr;

  bool get editing => widget.editId != null;

  @override
  void initState() {
    super.initState();
    final s = ref.read(appControllerProvider);
    final e = editing ? s.byId(widget.editId!) : null;
    titleC = TextEditingController(text: e?.title ?? '');
    amountC = TextEditingController(
      text: e == null ? '' : plainAmount(e.amount),
    );
    noteC = TextEditingController(text: e?.note ?? '');
    cur = e?.currency ?? s.disp;
    category = e?.category ?? 'Food';
    date = e?.date ?? today();
  }

  @override
  void dispose() {
    titleC.dispose();
    amountC.dispose();
    noteC.dispose();
    super.dispose();
  }

  void _save() {
    final title = titleC.text.trim();
    final n = parseAmount(amountC.text.trim());
    String? te, ae;
    if (title.isEmpty) te = 'Enter a title';
    if (n == null) {
      ae = 'Enter a valid number';
    } else if (n <= 0) {
      ae = 'Amount must be greater than 0';
    }
    if (te != null || ae != null) {
      setState(() {
        titleErr = te;
        amountErr = ae;
      });
      return;
    }
    ref
        .read(appControllerProvider.notifier)
        .saveExpense(
          id: widget.editId,
          title: title,
          amount: n!,
          currency: cur,
          category: category,
          date: date,
          note: noteC.text.trim(),
        );
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ctrl = ref.read(appControllerProvider.notifier);
    final ok = await confirmDialog(
      context,
      'Delete expense?',
      'This expense will be removed.',
      'Delete',
    );
    if (ok && mounted) {
      ctrl.removeExpense(widget.editId!);
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => date = d);
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final s = ref.watch(appControllerProvider);
    final n = parseAmount(amountC.text) ?? 0;
    final preview =
        n > 0
            ? '≈ ${s.moneyIn(s.conv(n, cur, cur.other), cur.other)}'
            : 'Rate: 1 USD = ${fmt(s.rate)} PHP';

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit expense' : 'New expense'),
        actions: [
          if (editing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          TextField(
            controller: titleC,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(color: p.on, fontSize: 16),
            decoration: fieldDec(p, 'Title', error: titleErr),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<Cur>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: Cur.usd, label: Text('USD \$')),
                ButtonSegment(value: Cur.php, label: Text('PHP ₱')),
              ],
              selected: {cur},
              onSelectionChanged: (sel) => setState(() => cur = sel.first),
              style: SegmentedButton.styleFrom(
                foregroundColor: p.on,
                selectedForegroundColor: p.on,
                selectedBackgroundColor: p.sel,
                side: BorderSide(color: p.line),
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: amountC,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            onChanged: (_) => setState(() => amountErr = null),
            style: TextStyle(color: p.on, fontSize: 16),
            decoration: fieldDec(p, 'Amount (${cur.sym})', error: amountErr),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
            child: Text(preview, style: TextStyle(color: p.mut, fontSize: 12)),
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: category,
            dropdownColor: p.surface,
            style: TextStyle(color: p.on, fontSize: 16),
            decoration: fieldDec(p, 'Category'),
            items: [
              for (final c in cats)
                DropdownMenuItem(
                  value: c.name,
                  child: Text('${c.emoji} ${c.name}'),
                ),
            ],
            onChanged: (v) => setState(() => category = v ?? category),
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(14),
            child: InputDecorator(
              decoration: fieldDec(
                p,
                'Date',
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: p.mut,
                  size: 20,
                ),
              ),
              child: Text(
                ymd(date),
                style: TextStyle(color: p.on, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: noteC,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(color: p.on, fontSize: 16),
            decoration: fieldDec(p, 'Note (optional)'),
          ),
          const SizedBox(height: 18),
          PrimaryButton(label: editing ? 'Update' : 'Save', onPressed: _save),
        ],
      ),
    );
  }
}
