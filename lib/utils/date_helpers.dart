const monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String ymd(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// "Oct 30, 2026"
String prettyDate(DateTime d) =>
    '${monthNames[d.month - 1].substring(0, 3)} ${d.day}, ${d.year}';

DateTime today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}
