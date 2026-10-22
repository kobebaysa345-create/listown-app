import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listown/main.dart';
import 'package:listown/models/currency.dart';
import 'package:listown/providers/app_controller.dart';
import 'package:listown/views/dashboard_page.dart';

void main() {
  testWidgets('app launches into the LISTOWN onboarding screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ProviderScope(child: ExpenseApp()));
    await tester.pumpAndSettle();
    expect(find.text('LISTOWN'), findsWidgets);
    expect(find.text("Let's Get Started"), findsOneWidget);
  });

  testWidgets('dashboard updates when shared Riverpod state changes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(420, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final ctrl = container.read(appControllerProvider.notifier);
    ctrl.register(
      profileName: 'kobe',
      firstName: 'Kobe',
      lastName: 'B',
      pin: '1234',
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: DashboardPage()),
      ),
    );
    expect(find.text('No expenses this month yet.'), findsOneWidget);

    ctrl.saveExpense(
      title: 'Lunch',
      amount: 120,
      currency: Cur.php,
      category: 'Food',
      date: DateTime.now(),
      note: '',
    );
    await tester.pump();
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('No expenses this month yet.'), findsNothing);

    ctrl.removeExpense(container.read(appControllerProvider).items.single.id);
    await tester.pump();
    expect(find.text('Lunch'), findsNothing);
  });
}
