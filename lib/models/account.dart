import 'expense.dart';
import 'savings_challenge.dart';

/// A saved profile. Each account keeps its own PIN, expenses, savings
/// challenges and budget. Immutable: use [copyWith] to produce updates.
class Account {
  final String profileName, firstName, lastName;
  final String _pin;
  final List<Expense> items;
  final List<SavingsChallenge> challenges;
  final double budgetUsd;
  final int fails;
  final DateTime? lockedUntil;

  Account({
    required this.profileName,
    required this.firstName,
    required this.lastName,
    required String pin,
    List<Expense> items = const [],
    List<SavingsChallenge> challenges = const [],
    this.budgetUsd = 1000,
    this.fails = 0,
    this.lockedUntil,
  }) : _pin = pin,
       items = List.unmodifiable(items),
       challenges = List.unmodifiable(challenges);

  Account copyWith({
    List<Expense>? items,
    List<SavingsChallenge>? challenges,
    double? budgetUsd,
    int? fails,
    DateTime? lockedUntil,
    bool clearLock = false,
  }) => Account(
    profileName: profileName,
    firstName: firstName,
    lastName: lastName,
    pin: _pin,
    items: items ?? this.items,
    challenges: challenges ?? this.challenges,
    budgetUsd: budgetUsd ?? this.budgetUsd,
    fails: fails ?? this.fails,
    lockedUntil: clearLock ? null : (lockedUntil ?? this.lockedUntil),
  );

  bool checkPin(String v) => v == _pin;
  String get fullName => '$firstName $lastName'.trim();

  /// Seconds left on a PIN lockout (0 = not locked).
  int get lockLeft {
    final t = lockedUntil;
    if (t == null) return 0;
    final ms = t.difference(DateTime.now()).inMilliseconds;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }
}
