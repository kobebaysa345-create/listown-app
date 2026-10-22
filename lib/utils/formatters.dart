String fmt(double n) {
  final sign = n < 0 ? '-' : '';
  final parts = n.abs().toStringAsFixed(2).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ',',
  );
  return '$sign$whole.${parts[1]}';
}

/// Strict amount parser: commas are thousands separators ("1,500" = 1500),
/// junk such as "12abc" is rejected (returns null).
double? parseAmount(String v) {
  var s = v.replaceAll(RegExp(r'[,\s]'), '');
  if (!RegExp(r'^(\d+\.?\d*|\.\d+)$').hasMatch(s)) return null;
  if (s.endsWith('.')) s = '${s}0';
  return double.tryParse(s);
}

String plainAmount(double a) =>
    a == a.roundToDouble() ? a.toStringAsFixed(0) : a.toString();
