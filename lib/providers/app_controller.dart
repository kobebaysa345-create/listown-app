import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../models/app_state.dart';
import '../models/currency.dart';
import '../models/expense.dart';
import '../models/savings_challenge.dart';

/// Result of a wrong PIN attempt.
class FailedPinResult {
  final bool locked;
  final int triesLeft;
  const FailedPinResult({required this.locked, required this.triesLeft});
}

/// The single source of truth for LISTOWN. Every change builds a new
/// [AppStateData] and assigns it to `state`, so all watching screens rebuild.
final appControllerProvider = NotifierProvider<AppController, AppStateData>(
  AppController.new,
);

class AppController extends Notifier<AppStateData> {
  static const maxTries = 5;
  static const lockSeconds = 30;

  @override
  AppStateData build() => const AppStateData();

  // ───────────── helpers ─────────────

  /// Replaces the account that has the same profile name as [updated].
  void _replace(Account updated) {
    state = state.copyWith(
      accounts: [
        for (final a in state.accounts)
          a.profileName == updated.profileName ? updated : a,
      ],
    );
  }

  /// Applies [change] to the signed-in account only.
  void _updateCurrent(Account Function(Account a) change) {
    final cur = state.current;
    if (cur == null) return;
    _replace(change(cur));
  }

  // ───────────── accounts / auth ─────────────

  /// Adds a NEW account (existing ones are kept) and signs it in.
  void register({
    required String profileName,
    required String firstName,
    required String lastName,
    required String pin,
  }) {
    if (state.find(profileName) != null) return;
    final a = Account(
      profileName: profileName,
      firstName: firstName,
      lastName: lastName,
      pin: pin,
    );
    state = state.copyWith(
      accounts: [...state.accounts, a],
      currentProfile: a.profileName,
    );
  }

  bool checkPin(String profile, String pin) =>
      state.find(profile)?.checkPin(pin) ?? false;

  /// Records a wrong PIN. After [maxTries] misses the profile is locked for
  /// [lockSeconds] seconds.
  FailedPinResult registerFailedPin(String profile) {
    final a = state.find(profile);
    if (a == null) {
      return const FailedPinResult(locked: false, triesLeft: maxTries);
    }
    final fails = a.fails + 1;
    if (fails >= maxTries) {
      _replace(
        a.copyWith(
          fails: 0,
          lockedUntil: DateTime.now().add(const Duration(seconds: lockSeconds)),
        ),
      );
      return const FailedPinResult(locked: true, triesLeft: 0);
    }
    _replace(a.copyWith(fails: fails));
    return FailedPinResult(locked: false, triesLeft: maxTries - fails);
  }

  void clearLock(String profile) {
    final a = state.find(profile);
    if (a == null) return;
    _replace(a.copyWith(clearLock: true));
  }

  void logIn(String profile) {
    final a = state.find(profile);
    if (a == null) return;
    final fresh = a.copyWith(fails: 0, clearLock: true);
    state = state.copyWith(
      accounts: [
        for (final x in state.accounts) x.profileName == a.profileName ? fresh : x,
      ],
      currentProfile: a.profileName,
    );
  }

  void logOut() => state = state.copyWith(clearCurrent: true);

  /// Forgot-PIN path: removes only this account and its data.
  void removeAccount(String profile) {
    final a = state.find(profile);
    if (a == null) return;
    final wasCurrent = state.currentProfile == a.profileName;
    state = state.copyWith(
      accounts: [
        for (final x in state.accounts)
          if (x.profileName != a.profileName) x,
      ],
      clearCurrent: wasCurrent,
    );
  }

  // ───────────── expenses (CRUD) ─────────────

  /// Creates an expense (when [id] is null) or updates the one with [id].
  void saveExpense({
    int? id,
    required String title,
    required double amount,
    required Cur currency,
    required String category,
    required DateTime date,
    required String note,
  }) {
    final cur = state.current;
    if (cur == null) return;
    if (id != null) {
      final i = cur.items.indexWhere((e) => e.id == id);
      if (i < 0) return;
      final items = [...cur.items];
      items[i] = items[i].copyWith(
        title: title,
        amount: amount,
        currency: currency,
        category: category,
        date: date,
        note: note,
      );
      _replace(cur.copyWith(items: items));
    } else {
      final e = Expense(
        id: state.nextExpenseId,
        title: title,
        amount: amount,
        currency: currency,
        category: category,
        date: date,
        note: note,
      );
      _replace(cur.copyWith(items: [...cur.items, e]));
      state = state.copyWith(nextExpenseId: state.nextExpenseId + 1);
    }
  }

  void removeExpense(int id) => _updateCurrent(
    (a) => a.copyWith(items: [
      for (final e in a.items)
        if (e.id != id) e,
    ]),
  );

  /// Used by Undo: puts a deleted expense back (no duplicates).
  void restoreExpense(Expense e) => _updateCurrent((a) {
    if (a.items.any((x) => x.id == e.id)) return a;
    return a.copyWith(items: [...a.items, e]);
  });

  void clearExpenses() => _updateCurrent((a) => a.copyWith(items: const []));

  // ───────────── savings challenges (CRUD) ─────────────

  /// Creates a challenge (when [id] is null) or updates the one with [id].
  /// Updating keeps the amount already saved.
  void saveChallenge({
    int? id,
    required String name,
    required double goal,
    required Cur currency,
    required Freq freq,
    required DateTime finish,
  }) {
    final cur = state.current;
    if (cur == null) return;
    final existing = id == null ? null : state.challengeById(id);
    if (existing != null) {
      _replace(
        cur.copyWith(
          challenges: [
            for (final c in cur.challenges)
              c.id == id
                  ? c.copyWith(
                      name: name,
                      goal: goal,
                      currency: currency,
                      freq: freq,
                      finish: finish,
                    )
                  : c,
          ],
        ),
      );
    } else {
      final c = SavingsChallenge(
        id: state.nextChallengeId,
        name: name,
        goal: goal,
        currency: currency,
        freq: freq,
        finish: finish,
      );
      _replace(cur.copyWith(challenges: [...cur.challenges, c]));
      state = state.copyWith(nextChallengeId: state.nextChallengeId + 1);
    }
  }

  void addSavings(int id, double amount) => _updateCurrent(
    (a) => a.copyWith(
      challenges: [
        for (final c in a.challenges)
          c.id == id ? c.copyWith(saved: c.saved + amount) : c,
      ],
    ),
  );

  void removeChallenge(int id) => _updateCurrent(
    (a) => a.copyWith(
      challenges: [
        for (final c in a.challenges)
          if (c.id != id) c,
      ],
    ),
  );

  // ───────────── preferences ─────────────

  void setDisp(Cur c) => state = state.copyWith(disp: c);

  void toggleDisp() => setDisp(state.disp.other);

  void setRate(double r) => state = state.copyWith(rate: r);

  /// [x] is entered in the display currency; 0 disables the budget.
  void setBudgetFromDisplay(double x) {
    final usd = x <= 0 ? 0.0 : state.conv(x, state.disp, Cur.usd);
    _updateCurrent((a) => a.copyWith(budgetUsd: usd));
  }

  void setDark(bool v) =>
      state = state.copyWith(themeMode: v ? ThemeMode.dark : ThemeMode.light);
}
