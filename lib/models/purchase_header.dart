import 'package:my_financial_life/models/purchase_category.dart';

class PurchaseHeader {
  final String id;
  double totalValue;
  double notPaidValue;
  final String description;
  int installmentsQuantity;
  DateTime startDate;
  DateTime? nextPayDate;
  final String categoryId;
  final bool fullPaid;
  PurchaseCategory? category;
  int? installmentsPaidQuantity;

  PurchaseHeader({
    required this.id,
    required this.totalValue,
    required this.notPaidValue,
    required this.description,
    required this.installmentsQuantity,
    required this.startDate,
    required this.nextPayDate,
    required this.categoryId,
    required this.fullPaid,
    required this.installmentsPaidQuantity,
    this.category,
  });
}