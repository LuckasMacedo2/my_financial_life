import 'package:my_financial_life/models/purchase_category.dart';

class Earning {
  String id;
  double value;
  double? profit;
  DateTime date;
  String description;
  String? observation;
  String categoryId;
  PurchaseCategory? category;

  Earning({
    required this.id,
    required this.value,
    required this.date,
    required this.description,
    required this.categoryId,
    this.category,
    this.observation,
    this.profit,
  });

}