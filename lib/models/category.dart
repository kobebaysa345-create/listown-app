import 'package:flutter/painting.dart' show Color;

class Cat {
  final String name, emoji;
  final Color color;
  const Cat(this.name, this.emoji, this.color);
}

const cats = [
  Cat('Food', '🍽️', Color(0xFFF59E0B)),
  Cat('Transport', '🚌', Color(0xFF3B82F6)),
  Cat('Shopping', '🛍️', Color(0xFFEC4899)),
  Cat('Bills', '🧾', Color(0xFF14B8A6)),
  Cat('Health', '❤️', Color(0xFFEF4444)),
  Cat('Entertainment', '🎬', Color(0xFFA855F7)),
  Cat('Other', '📦', Color(0xFF9CA3AF)),
];

Cat catOf(String n) =>
    cats.firstWhere((c) => c.name == n, orElse: () => cats.last);
