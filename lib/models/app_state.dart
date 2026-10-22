import 'package:flutter/material.dart' show ThemeMode;

import '../utils/formatters.dart';
import 'account.dart';
import 'currency.dart';
import 'expense.dart';
import 'savings_challenge.dart';

/// Immutable snapshot of the whole application. It is only ever replaced
/// (never mutated) by `AppController`, which is what lets Riverpod notify
/// every watching screen.
class AppStateData {
  final Cur disp;
  final double rate;
  final ThemeMode themeMode;
  final List<Account> accounts;

  /// `profileName` of the signed-in account, or null when logged out.
  final String? currentProfile;
  final int nextExpenseId;
  final int nextChallengeId;

  const AppStateData({
    this.disp = Cur.usd,
    this.rate = 61.5,
    this.themeMode = ThemeMode.system,
    this.accounts = const [],
    this.currentProfile,
    this.nextExpenseId = 11,
    this.nextChallengeId = 1,
  });

  AppStateData copyWith({
    Cur? disp,
    double? rate,
    ThemeMode? themeMode,
    List<Account>? accounts,
    String? currentProfile,
    bool clearCurrent = false,
    int? nextExpenseId,
    int? nextChallengeId,
  }) => AppStateData(
    disp: disp ?? this.disp,
    rate: rate ?? this.rate,
    themeMode: themeMode ?? this.themeMode,
    accounts: accounts == null ? this.accounts : List.unmodifiable(accounts),
    currentProfile: clearCurrent
        ? null
        : (currentProfile ?? this.currentProfile),
    nextExpenseId: nextExpenseId ?? this.nextExpenseId,
    nextChallengeId: nextChallengeId ?? this.nextChallengeId,
  );

  // ── Accounts ──

  /// Case-insensitive profile lookup.
  Account? find(String name) {
    final n = name.trim().toLowerCase();
    for (final a in accounts) {
      if (a.profileName.toLowerCase() == n) return a;
    }
    return null;
  }

  Account? get current {
    final p = currentProfile;
    if (p == null) return null;
    for (final a in accounts) {
      if (a.profileName == p) return a;
    }
    return null;
  }

  bool get hasAccount => accounts.isNotEmpty;
  bool get loggedIn => current != null;
  String get profileName => current?.profileName ?? '';
  String get firstName => current?.firstName ?? '';
  String get lastName => current?.lastName ?? '';

  // ── Data of the signed-in account ──

  List<Expense> get items => current?.items ?? const [];
  List<SavingsChallenge> get challenges => current?.challenges ?? const [];
  double get budgetUsd => current?.budgetUsd ?? 0;

  // ── Conversion / formatting ──

  double conv(double a, Cur f, Cur t) =>
      f == t ? a : (f == Cur.usd ? a * rate : a / rate);
  String moneyIn(double n, Cur c) => '${c.sym}${fmt(n)}';
  String money(double n) => moneyIn(n, disp);
  double inD(Expense e) => conv(e.amount, e.currency, disp);
  double get budD => conv(budgetUsd, Cur.usd, disp);

  // ── Queries ──

  List<Expense> get sorted {
    final l = [...items];
    l.sort((a, b) {
      final c = b.date.compareTo(a.date);
      return c != 0 ? c : b.id.compareTo(a.id);
    });
    return l;
  }

  /// Expenses that fall in the same month as [m].
  List<Expense> monthItemsFor(DateTime m) => items
      .where((e) => e.date.year == m.year && e.date.month == m.month)
      .toList();

  List<Expense> get monthItems => monthItemsFor(DateTime.now());

  /// First day of the oldest month that has an expense (null if none).
  DateTime? get earliestMonth {
    if (items.isEmpty) return null;
    var min = items.first.date;
    for (final e in items) {
      if (e.date.isBefore(min)) min = e.date;
    }
    return DateTime(min.year, min.month);
  }

  Expense? byId(int id) {
    for (final e in items) {
      if (e.id == id) return e;
    }
    return null;
  }

  SavingsChallenge? challengeById(int id) {
    for (final c in challenges) {
      if (c.id == id) return c;
    }
    return null;
  }
}
