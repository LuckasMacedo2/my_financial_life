import 'dart:ui';

class CreditCard {
  final String id;
  final String name;
  final double limit;
  final Color color;
  double? usedLimit = 0;

  CreditCard({
    required this.id,
    required this.name,
    required this.limit,
    required this.color,
    this.usedLimit,
  });
}
