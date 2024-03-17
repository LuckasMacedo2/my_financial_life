import 'dart:ui';

class PurchaseCategory {
  final String id;
  final String name;
  final String? description;
  final Color color;

  PurchaseCategory({required this.id, required this.name, this.description, required this.color});
}