import 'package:my_financial_life/models/purchase_category.dart';

class Purchases {
  final String id;
  final double value;
  final String? description;
  final int installmentsQuantity;
  final String? creditCardId;
  final DateTime date;
  final PurchaseCategory category;
  final String categoryId;

  Purchases({required this.id, required this.value, required this.installmentsQuantity, required this.date, required this.category, required this.categoryId, this.description, this.creditCardId});
}

enum PaymentForm {
  CreditCard,
  Money,
  BankBillet
}