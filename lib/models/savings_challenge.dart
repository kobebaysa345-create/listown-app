import 'dart:math' as math;

import '../utils/date_helpers.dart';
import 'currency.dart';

enum Freq { daily, weekly, monthly }

extension FreqX on Freq {
  String get label => this == Freq.daily
      ? 'Daily'
      : this == Freq.weekly
      ? 'Weekly'
      : 'Monthly';

  /// "day" / "week" / "month"
  String get unit => this == Freq.daily
      ? 'day'
      : this == Freq.weekly
      ? 'week'
      : 'month';
}

/// How many saving periods are left from today until [finish] (at least 1).
int periodsLeft(Freq f, DateTime finish) {
  final t = today();
  final days = DateTime.utc(
    finish.year,
    finish.month,
    finish.day,
  ).difference(DateTime.utc(t.year, t.month, t.day)).inDays;
  final d = days < 1 ? 1 : days;
  switch (f) {
    case Freq.daily:
      return d;
    case Freq.weekly:
      return (d / 7).ceil();
    case Freq.monthly:
      return (d / 30).ceil();
  }
}

class SavingsChallenge {
  final int id;
  final String name;
  final double goal;
  final double saved;
  final Cur currency;
  final Freq freq;
  final DateTime finish;

  const SavingsChallenge({
    required this.id,
    required this.name,
    required this.goal,
    required this.currency,
    required this.freq,
    required this.finish,
    this.saved = 0,
  });

  SavingsChallenge copyWith({
    String? name,
    double? goal,
    double? saved,
    Cur? currency,
    Freq? freq,
    DateTime? finish,
  }) => SavingsChallenge(
    id: id,
    name: name ?? this.name,
    goal: goal ?? this.goal,
    saved: saved ?? this.saved,
    currency: currency ?? this.currency,
    freq: freq ?? this.freq,
    finish: finish ?? this.finish,
  );

  double get remaining => math.max(goal - saved, 0);
  double get progress => goal > 0 ? (saved / goal).clamp(0.0, 1.0) : 0.0;
  bool get done => saved >= goal;
  bool get pastDue => !finish.isAfter(today());

  /// Amount to put aside every day / week / month to reach the goal.
  double get perPeriod => remaining / periodsLeft(freq, finish);
}
