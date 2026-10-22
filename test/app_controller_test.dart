import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listown/models/currency.dart';
import 'package:listown/models/savings_challenge.dart';
import 'package:listown/providers/app_controller.dart';

ProviderContainer makeContainer() {
  final c = ProviderContainer();
  addTearDown(c.dispose);
  return c;
}

void registerKobe(ProviderContainer c, {String profile = 'kobe'}) {
  c
      .read(appControllerProvider.notifier)
      .register(
        profileName: profile,
        firstName: 'Kobe',
        lastName: 'B',
        pin: '1234',
      );
}

void addLunch(ProviderContainer c, {double amount = 100}) {
  c
      .read(appControllerProvider.notifier)
      .saveExpense(
        title: 'Lunch',
        amount: amount,
        currency: Cur.php,
        category: 'Food',
        date: DateTime.now(),
        note: '',
      );
}

void main() {
  group('accounts', () {
    test('register signs in and rejects duplicate profile names', () {
      final c = makeContainer();
      registerKobe(c);
      registerKobe(c, profile: 'KOBE'); // same name, different case
      final s = c.read(appControllerProvider);
      expect(s.accounts.length, 1);
      expect(s.loggedIn, isTrue);
      expect(s.profileName, 'kobe');
    });

    test('expenses and challenges are isolated per account', () {
      final c = makeContainer();
      final ctrl = c.read(appControllerProvider.notifier);
      registerKobe(c);
      addLunch(c);
      ctrl.logOut();
      registerKobe(c, profile: 'second');
      expect(c.read(appControllerProvider).items, isEmpty);
      ctrl.logOut();
      ctrl.logIn('kobe');
      expect(c.read(appControllerProvider).items.length, 1);
    });

    test('wrong PIN locks the profile after 5 tries', () {
      final c = makeContainer();
      final ctrl = c.read(appControllerProvider.notifier);
      registerKobe(c);
      ctrl.logOut();
      expect(ctrl.checkPin('kobe', '1234'), isTrue);
      expect(ctrl.checkPin('kobe', '0000'), isFalse);
      for (var i = 1; i <= 4; i++) {
        final r = ctrl.registerFailedPin('kobe');
        expect(r.locked, isFalse);
        expect(r.triesLeft, 5 - i);
      }
      final last = ctrl.registerFailedPin('kobe');
      expect(last.locked, isTrue);
      expect(c.read(appControllerProvider).find('kobe')!.lockLeft, greaterThan(0));
      ctrl.clearLock('kobe');
      expect(c.read(appControllerProvider).find('kobe')!.lockLeft, 0);
    });

    test('forgot PIN removes only that account', () {
      final c = makeContainer();
      final ctrl = c.read(appControllerProvider.notifier);
      registerKobe(c);
      registerKobe(c, profile: 'other');
      ctrl.removeAccount('other');
      final s = c.read(appControllerProvider);
      expect(s.accounts.map((a) => a.profileName), ['kobe']);
      expect(s.loggedIn, isFalse);
    });
  });

  group('expense CRUD', () {
    test('create, read, update (no duplicate), delete and undo', () {
      final c = makeContainer();
      final ctrl = c.read(appControllerProvider.notifier);
      registerKobe(c);

      addLunch(c);
      var s = c.read(appControllerProvider);
      expect(s.items.length, 1);
      final created = s.items.single;
      expect(created.id, 11);

      ctrl.saveExpense(
        id: created.id,
        title: 'Dinner',
        amount: 250,
        currency: Cur.php,
        category: 'Food',
        date: created.date,
        note: 'edited',
      );
      s = c.read(appControllerProvider);
      expect(s.items.length, 1);
      expect(s.byId(created.id)!.title, 'Dinner');

      final removed = s.byId(created.id)!;
      ctrl.removeExpense(created.id);
      expect(c.read(appControllerProvider).items, isEmpty);

      ctrl.restoreExpense(removed);
      ctrl.restoreExpense(removed); // second undo must not duplicate
      expect(c.read(appControllerProvider).items.length, 1);
    });

    test('clearExpenses only clears the signed-in account', () {
      final c = makeContainer();
      final ctrl = c.read(appControllerProvider.notifier);
      registerKobe(c);
      addLunch(c);
      ctrl.logOut();
      registerKobe(c, profile: 'other');
      addLunch(c);
      ctrl.clearExpenses();
      ctrl.logIn('kobe');
      expect(c.read(appControllerProvider).items.length, 1);
    });
  });

  group('currency and budget', () {
    test('rate and display currency change conversions', () {
      final c = makeContainer();
      final ctrl = c.read(appControllerProvider.notifier);
      registerKobe(c);
      addLunch(c, amount: 615); // PHP
      ctrl.setRate(60);
      var s = c.read(appControllerProvider);
      expect(s.inD(s.items.single), 615 / 60); // shown in USD
      ctrl.setDisp(Cur.php);
      s = c.read(appControllerProvider);
      expect(s.inD(s.items.single), 615);
    });

    test('budget is entered in display currency and stored in USD', () {
      final c = makeContainer();
      final ctrl = c.read(appControllerProvider.notifier);
      registerKobe(c);
      ctrl.setRate(60);
      ctrl.setDisp(Cur.php);
      ctrl.setBudgetFromDisplay(6000);
      expect(c.read(appControllerProvider).budgetUsd, 100);
      ctrl.setBudgetFromDisplay(0);
      expect(c.read(appControllerProvider).budgetUsd, 0);
    });
  });

  group('savings challenge CRUD', () {
    final finish = DateTime.now().add(const Duration(days: 30));

    test('create, add savings, edit keeps progress, delete', () {
      final c = makeContainer();
      final ctrl = c.read(appControllerProvider.notifier);
      registerKobe(c);

      ctrl.saveChallenge(
        name: 'Thesis',
        goal: 3000,
        currency: Cur.php,
        freq: Freq.weekly,
        finish: finish,
      );
      var s = c.read(appControllerProvider);
      expect(s.challenges.length, 1);
      final id = s.challenges.single.id;

      ctrl.addSavings(id, 500);
      ctrl.addSavings(id, 250);
      s = c.read(appControllerProvider);
      expect(s.challengeById(id)!.saved, 750);
      expect(s.challengeById(id)!.remaining, 2250);

      ctrl.saveChallenge(
        id: id,
        name: 'Thesis 2',
        goal: 4000,
        currency: Cur.php,
        freq: Freq.daily,
        finish: finish,
      );
      s = c.read(appControllerProvider);
      expect(s.challenges.length, 1);
      expect(s.challengeById(id)!.name, 'Thesis 2');
      expect(s.challengeById(id)!.saved, 750); // progress preserved

      ctrl.removeChallenge(id);
      expect(c.read(appControllerProvider).challenges, isEmpty);
    });

    test('per-period amount and completion', () {
      final c = makeContainer();
      final ctrl = c.read(appControllerProvider.notifier);
      registerKobe(c);
      ctrl.saveChallenge(
        name: 'Gadget',
        goal: 700,
        currency: Cur.php,
        freq: Freq.weekly,
        finish: DateTime.now().add(const Duration(days: 14)),
      );
      final id = c.read(appControllerProvider).challenges.single.id;
      final ch = c.read(appControllerProvider).challengeById(id)!;
      expect(ch.perPeriod, closeTo(700 / periodsLeft(Freq.weekly, ch.finish), 1e-9));
      ctrl.addSavings(id, 700);
      expect(c.read(appControllerProvider).challengeById(id)!.done, isTrue);
    });

    test('challenges are isolated per account', () {
      final c = makeContainer();
      final ctrl = c.read(appControllerProvider.notifier);
      registerKobe(c);
      ctrl.saveChallenge(
        name: 'A',
        goal: 100,
        currency: Cur.usd,
        freq: Freq.daily,
        finish: finish,
      );
      ctrl.logOut();
      registerKobe(c, profile: 'other');
      expect(c.read(appControllerProvider).challenges, isEmpty);
    });
  });

  test('theme preference updates state', () {
    final c = makeContainer();
    c.read(appControllerProvider.notifier).setDark(true);
    expect(c.read(appControllerProvider).themeMode.name, 'dark');
  });
}
