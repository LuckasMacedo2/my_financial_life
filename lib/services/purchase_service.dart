import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_financial_life/exceptions/http_exception.dart';
import 'package:my_financial_life/models/credit_cart.dart';
import 'package:my_financial_life/models/purchase.dart';
import 'package:my_financial_life/models/purchase_category.dart';
import 'package:my_financial_life/utils/constants.dart';

class PurchaseService with ChangeNotifier {
  List<Purchase> _items = [];
  List<Purchase> get items => [..._items];
  int get itemsCount {
    return _items.length;
  }

  Future<void> loadPurchase() async {
    _items.clear();

    final response = await http
        .get(Uri.parse('${Constants.PURCHASE_BASE_URL}.json'));

    if (response.body == 'null') return;

    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((purcId, purc) {
      _items.add(
        Purchase(
          id: purcId,
          value: purc['value'],
          description: purc['description'],
          installmentsQuantity: purc['installmentsQuantity'],
          creditCardId: purc['creditCardId'],
          date:  DateTime.parse(purc['date']),
          categoryId: purc['categoryId'],
        ),
      );
    });
    notifyListeners();
  }

  Future<void> savePurchase(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final purc = Purchase(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      value: double.parse(data['value'].toString()),
      description: data['description'] as String,
      date: DateTime.parse(data['date'].toString()),
      installmentsQuantity: int.parse(data['installmentsQuantity'].toString()),
      creditCardId: data['creditCardId'] as String,
      categoryId: data['categoryId'] as String,
    );

    if (hasId)
      return updatePurchase(purc);
    else
      return addPurchase(purc);
  }

  Future<void> updatePurchase(Purchase purc) async {
    int index = _items.indexWhere((p) => p.id == purc.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse(
            '${Constants.PURCHASE_BASE_URL}/${purc.id}.json'), // No firebase a URL deve terminar com .json
        body: jsonEncode(
          {
            "value": purc.value,
            "description": purc.description,
            "date": purc.date.toIso8601String(),
            "installmentsQuantity": purc.installmentsQuantity,
            "creditCardId": purc.creditCardId,
            "categoryId": purc.categoryId,
          },
        ),
      );

      _items[index] = purc;
      notifyListeners();
    }
  }

  Future<void> addPurchase(Purchase purc) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${Constants.PURCHASE_BASE_URL}.json'), // No firebase a URL deve terminar com .json
        body: jsonEncode(
          {
            "value": purc.value,
            "description": purc.description,
            "date": purc.date.toIso8601String(),
            "installmentsQuantity": purc.installmentsQuantity,
            "creditCardId": purc.creditCardId,
            "categoryId": purc.categoryId,
          },
        ),
      );

      final id = jsonDecode(response.body)['name'];
      _items.add(
        Purchase(
          id: id,
          value: purc.value,
          description: purc.description,
          date: purc.date,
          installmentsQuantity: purc.installmentsQuantity,
          creditCardId: purc.creditCardId,
          categoryId: purc.categoryId,
        ),
      );
      notifyListeners(); // Chama o notificador sempre que houver uma mudança na lista
    } catch (error) {
      print(error);
    }
  }

  Future<void> removePurchase(Purchase purc) async {
    int index = _items.indexWhere((p) => p.id == purc.id);
    if (index >= 0) {
      final purc = _items[index];
      _items.remove(purc);
      notifyListeners();

      final response = await http.delete(
        Uri.parse(
            '${Constants.PURCHASE_BASE_URL}/${purc.id}.json'), // No firebase a URL deve terminar com .json
      );

      if (response.statusCode >= 400) {
        _items.insert(index, purc);
        notifyListeners();
        throw HttpException(
          msg: 'Não foi possível excluir a compra',
          statusCode: response.statusCode,
        );
      }
    }
  }
}
