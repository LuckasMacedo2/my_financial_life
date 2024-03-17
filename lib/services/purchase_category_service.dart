import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_financial_life/exceptions/http_exception.dart';
import 'package:my_financial_life/models/credit_cart.dart';
import 'package:my_financial_life/models/purchase_category.dart';
import 'package:my_financial_life/utils/constants.dart';

class PurchaseCategoryService with ChangeNotifier {
  List<PurchaseCategory> _items = [];
  List<PurchaseCategory> get items => [..._items];
  int get itemsCount {
    return _items.length;
  }

  Future<void> loadPurchaseCategory() async {
    _items.clear();

    final response = await http
        .get(Uri.parse('${Constants.PURCHASE_CATEGORY_BASE_URL}.json'));

    if (response.body == 'null') return;

    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((purcCategoryId, purcCategory) {
      _items.add(
        PurchaseCategory(
          id: purcCategoryId,
          name: purcCategory['name'],
          description: purcCategory['description'],
          color: Color(purcCategory['color']),
        ),
      );
    });
    notifyListeners();
  }

  Future<void> savePurchaseCategory(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final purcCategory = PurchaseCategory(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      color: data['color'] as Color,
    );

    if (hasId)
      return updatePurchaseCategory(purcCategory);
    else
      return addPurchaseCategory(purcCategory);
  }

  Future<void> updatePurchaseCategory(PurchaseCategory purcCategory) async {
    int index = _items.indexWhere((p) => p.id == purcCategory.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse(
            '${Constants.PURCHASE_CATEGORY_BASE_URL}/${purcCategory.id}.json'), // No firebase a URL deve terminar com .json
        body: jsonEncode(
          {
            "name": purcCategory.name,
            "description": purcCategory.description,
            "color": purcCategory.color.value,
          },
        ),
      );

      _items[index] = purcCategory;
      notifyListeners();
    }
  }

  Future<void> addPurchaseCategory(PurchaseCategory purcCategory) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${Constants.PURCHASE_CATEGORY_BASE_URL}.json'), // No firebase a URL deve terminar com .json
        body: jsonEncode(
          {
            "name": purcCategory.name,
            "description": purcCategory.description,
            "color": purcCategory.color.value,
          },
        ),
      );

      final id = jsonDecode(response.body)['name'];
      _items.add(
        PurchaseCategory(
          id: id,
          name: purcCategory.name,
          description: purcCategory.description,
          color: purcCategory.color
        ),
      );
      notifyListeners(); // Chama o notificador sempre que houver uma mudança na lista
    } catch (error) {
      print(error);
    }
  }

  Future<void> removePurchaseCategory(PurchaseCategory purcCategory) async {
    int index = _items.indexWhere((p) => p.id == purcCategory.id);
    if (index >= 0) {
      final purcCategory = _items[index];
      _items.remove(purcCategory);
      notifyListeners();

      final response = await http.delete(
        Uri.parse(
            '${Constants.PURCHASE_CATEGORY_BASE_URL}/${purcCategory.id}.json'), // No firebase a URL deve terminar com .json
      );

      if (response.statusCode >= 400) {
        _items.insert(index, purcCategory);
        notifyListeners();
        throw HttpException(
          msg: 'Não foi possível excluir o produto',
          statusCode: response.statusCode,
        );
      }
    }
  }
}
