import 'package:my_financial_life/models/purchase_category.dart';

class Purchase {
  final String id;
  double value;
  final String description;
  int installmentsQuantity;
  final String? creditCardId;
  DateTime date;
  PurchaseCategory? category;
  final String categoryId;
  final bool paid;
  String billId;

  Purchase({
    required this.id,
    required this.value,
    required this.installmentsQuantity,
    required this.date,
    required this.categoryId,
    required this.description,
    required this.paid,
    required this.billId,
    this.creditCardId,
    this.category,
  });
}

enum PaymentForm { CreditCard, Money, BankBillet }
