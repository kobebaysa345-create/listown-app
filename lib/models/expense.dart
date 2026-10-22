import 'currency.dart';

class Expense {
  final int id;
  final String title;
  final double amount;
  final Cur currency;
  final String category;
  final DateTime date;
  final String note;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    required this.note,
  });

  Expense copyWith({
    String? title,
    double? amount,
    Cur? currency,
    String? category,
    DateTime? date,
    String? note,
  }) => Expense(
    id: id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    category: category ?? this.category,
    date: date ?? this.date,
    note: note ?? this.note,
  );
}
