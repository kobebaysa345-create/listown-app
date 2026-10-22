import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../providers/app_controller.dart';
import '../theme/palette.dart';
import '../utils/navigation.dart';
import '../widgets/app_bars.dart';
import '../widgets/expense_tile.dart';
import 'expense_form_page.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  String q = '';
  String? catFilter;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final s = ref.watch(appControllerProvider);
    final ctrl = ref.read(appControllerProvider.notifier);
    final qq = q.trim().toLowerCase();
    final f = s.sorted
        .where(
          (e) =>
              (qq.isEmpty ||
                  e.title.toLowerCase().contains(qq) ||
                  e.note.toLowerCase().contains(qq)) &&
              (catFilter == null || e.category == catFilter),
        )
        .toList();
    final t = f.fold<double>(0, (sum, e) => sum + s.inD(e));

    return Scaffold(
      appBar: pageBar(context, 'Expenses'),
      floatingActionButton: AddExpenseFab(
        onPressed: () => go(context, const ExpenseFormPage()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => q = v),
              style: TextStyle(color: p.on, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search expenses',
                hintStyle: TextStyle(color: p.mut),
                prefixIcon: Icon(Icons.search, color: p.mut),
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
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _chip(
                  p,
                  'All',
                  catFilter == null,
                  () => setState(() => catFilter = null),
                ),
                for (final c in cats)
                  _chip(
                    p,
                    '${c.emoji} ${c.name}',
                    catFilter == c.name,
                    () => setState(() => catFilter = c.name),
                  ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: p.line)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${f.length} item(s)',
                  style: TextStyle(color: p.on, fontSize: 13),
                ),
                Text(
                  'Total: ${s.money(t)}',
                  style: TextStyle(
                    color: p.on,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: f.isEmpty
                ? Center(
                    child: Text(
                      'No expenses found.',
                      style: TextStyle(color: p.mut, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                    itemCount: f.length,
                    itemBuilder: (context, i) {
                      final e = f[i];
                      return Dismissible(
                        key: ValueKey(e.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: fade(p.red, .25),
                          child: Icon(Icons.delete_outline, color: p.red),
                        ),
                        onDismissed: (_) {
                          ctrl.removeExpense(e.id);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text('Deleted “${e.title}”'),
                                duration: const Duration(seconds: 4),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  onPressed: () => ctrl.restoreExpense(e),
                                ),
                              ),
                            );
                        },
                        child: ExpenseTile(
                          e,
                          onTap: () =>
                              go(context, ExpenseFormPage(editId: e.id)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(Palette p, String label, bool on, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: on,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      selectedColor: p.sel,
      backgroundColor: Colors.transparent,
      labelStyle: TextStyle(
        color: p.on,
        fontSize: 13,
        fontWeight: on ? FontWeight.w700 : FontWeight.w400,
      ),
      side: BorderSide(color: on ? p.on : p.line, width: on ? 1.5 : 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
