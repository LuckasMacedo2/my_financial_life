import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_financial_life/exceptions/http_exception.dart';
import 'package:my_financial_life/models/purchase.dart';
import 'package:my_financial_life/utils/constants.dart';
import 'package:my_financial_life/utils/utils.dart';

class PurchaseService with ChangeNotifier {
  List<Purchase> _items = [];
  List<Purchase> get items => [..._items];
  int get itemsCount {
    return _items.length;
  }

  double sumValues() {
    double total = 0.0;
    _items.forEach((purc) {
      total += purc.value;
    });
    return total;
  }

  double sumNotPaid() {
    double total = 0.0;
    _items.forEach((purc) {
      if(!purc.paid)
        total += purc.value;
    });
    return total;
  }

  double diff() {
    return sumValues() - sumNotPaid();
  }

  double sumPurchasesByCreditCardId(String creditCardId) {
    double total = 0.0;
    _items.forEach((purc) {
      if(!purc.paid && purc.creditCardId == creditCardId)
        total += purc.value;
    });
    return total;
  }

  Future<double> getSumPurchasesNotByCreditCardId(String creditCardId) async {
    if(itemsCount == 0) await loadPurchase();
    return Future(() => sumPurchasesByCreditCardId(creditCardId));
  }

  double sumPurchasesByCreditCard() {
    double total = 0.0;
    _items.forEach((purc) {
      if(!purc.paid && purc.creditCardId != "")
        total += purc.value;
    });
    return total;
  }

  Future<double> getSumPurchasesNotByCreditCard() async {
    if(itemsCount == 0) await loadPurchase();
    return Future(() => sumPurchasesByCreditCard());
  }

  Future<void> loadPurchase() async {
    _items.clear();

    final response =
        await http.get(Uri.parse('${Constants.PURCHASE_BASE_URL}.json'));

    if (response.body == 'null') return;

    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((purcId, purc) {
      _items.add(Purchase(
        id: purcId,
        value: purc['value'],
        description: purc['description'],
        installmentsQuantity: purc['installmentsQuantity'],
        creditCardId: purc['creditCardId'] ?? '',
        date: DateTime.parse(purc['date']),
        categoryId: purc['categoryId'],
        paid: purc['paid'].toString().toUpperCase() == 'TRUE',
      ));
    });
    _items.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  Future<void> savePurchase(Map<String, Object> data) async {
    bool hasId = data['id'] != null;

    final purc = Purchase(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      value: double.parse(data['value'].toString()),
      description: data['description'] as String,
      date: DateTime.parse(data['date'].toString()),
      installmentsQuantity: int.parse(data['installmentsQuantity'].toString()),
      creditCardId: data['creditCardId'] as String,
      categoryId: data['categoryId'] as String,
      paid: data['paid'] as bool,
    );

    if (purc.installmentsQuantity > 1) {
      double valuePerMounth = purc.value / purc.installmentsQuantity;
      int orignalInstallmentsQuantity = purc.installmentsQuantity;
      DateTime originalDate = purc.date;
      // Purchase newPurc = ...purc;
      for (int i = 0; i < orignalInstallmentsQuantity; i++) {
        purc.date = Utils().addMonthsToDate(originalDate, i);
        purc.installmentsQuantity = 1;
        purc.value = valuePerMounth;
        await insertOrUpdate(purc, hasId);
      }
      return new Future(() => null);
    } else {
      return insertOrUpdate(purc, hasId);
    }
  }

  Future<void> insertOrUpdate(Purchase purc, bool hasId) {
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
            "paid": purc.paid,
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
            "paid": purc.paid,
          },
        ),
      );

      final id = jsonDecode(response.body)['name'];
      _items.add(
        new Purchase(
          id: id,
          value: purc.value,
          description: purc.description,
          date: purc.date,
          installmentsQuantity: purc.installmentsQuantity,
          creditCardId: purc.creditCardId,
          categoryId: purc.categoryId,
          paid: purc.paid,
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
