import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_financial_life/data/cache_manager.dart';
import 'package:my_financial_life/exceptions/http_exception.dart';
import 'package:my_financial_life/models/purchase.dart';
import 'package:my_financial_life/models/purchase_header.dart';
import 'package:my_financial_life/utils/cache_constants.dart';
import 'package:my_financial_life/utils/constants.dart';
import 'package:my_financial_life/utils/utils.dart';
import 'package:uuid/uuid.dart';

class PurchaseService with ChangeNotifier {
  List<Purchase> _items = [];
  List<Purchase> get items => [..._items];
  int get itemsCount {
    return _items.length;
  }

  List<PurchaseHeader> _itemsHeader = [];
  List<PurchaseHeader> get itemsHeader => [..._itemsHeader];
  int get _itemsHeaderCount {
    return _itemsHeader.length;
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
      if (!purc.paid) total += purc.value;
    });
    return total;
  }

  double diff() {
    return sumValues() - sumNotPaid();
  }

  double sumPurchasesByCreditCardId(String creditCardId) {
    double total = 0.0;
    _items.forEach((purc) {
      if (!purc.paid && purc.creditCardId == creditCardId) total += purc.value;
    });
    return total;
  }

  Future<double> getSumPurchasesNotByCreditCardId(String creditCardId) async {
    if (itemsCount == 0) await loadPurchase();
    return Future(() => sumPurchasesByCreditCardId(creditCardId));
  }

  double sumPurchasesByCreditCard() {
    double total = 0.0;
    _items.forEach((purc) {
      if (!purc.paid && purc.creditCardId != "") total += purc.value;
    });
    return total;
  }

  Future<double> getSumPurchasesNotByCreditCard() async {
    if (itemsCount == 0) await loadPurchase();
    return Future(() => sumPurchasesByCreditCard());
  }

  Future<void> loadPurchase() async {
    _items.clear();

    final response =
        await http.get(Uri.parse('${Constants.PURCHASE_BASE_URL}.json'));

    if (response.body == 'null') return;

    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((purcId, purc) {
      _items.add(
        Purchase(
            id: purcId,
            value: purc['value'],
            description: purc['description'],
            installmentsQuantity: purc['installmentsQuantity'],
            creditCardId: purc['creditCardId'] ?? '',
            date: DateTime.parse(purc['date']),
            categoryId: purc['categoryId'],
            paid: purc['paid'].toString().toUpperCase() == 'TRUE',
            billId: purc['billId']),
      );
    });
    _items.sort((a, b) => a.date.compareTo(b.date));
    _setPurchaseHeader();
    notifyListeners();
  }

  void _setPurchaseHeader() {
    var groupedPurchases = getAllDistinctKeys();

    for (int i = 0; i < groupedPurchases.length; i++) {
      String billId = groupedPurchases[i].billId;
      List<Purchase> purchases = getPurchaseByBillId(billId);

      bool fullPaid = purchases.length == countPurchasesPaidByBillId(purchases);

      _itemsHeader.add(
        PurchaseHeader(
          id: groupedPurchases[i].billId,
          totalValue: sumPurchasesByBillId(purchases),
          notPaidValue: sumPurchasesNotPaidByBillId(purchases),
          description: groupedPurchases[i].description,
          installmentsQuantity: purchases.length,
          startDate: getMinimumDate(purchases),
          nextPayDate: geNextPaidDate(purchases),
          categoryId: groupedPurchases[i].categoryId,
          fullPaid: fullPaid,
        ),
      );
    }
  }

  getMinimumDate(List<Purchase> purchases) {
    if (purchases.length == 0) {
      return null; // Retorna null se a lista estiver vazia
    }

    DateTime minDate = purchases[0].date;

    purchases.forEach((purchase) {
      if (purchase.date.isBefore(minDate)) {
        minDate = purchase.date;
      }
    });

    return minDate;
  }

  DateTime? geNextPaidDate(List<Purchase> purchases) {
    // Filtra as compras onde paid é true
    List<Purchase> paidPurchases =
        purchases.where((purchase) => !purchase.paid).toList();

    if (paidPurchases.isEmpty) {
      return null; // Retorna null se não houver compras pagas na lista
    }

    // Encontra a data mínima entre as compras pagas
    DateTime minPaidDate = paidPurchases[0].date;
    for (var purchase in paidPurchases) {
      if (purchase.date.isBefore(minPaidDate)) {
        minPaidDate = purchase.date;
      }
    }

    return minPaidDate;
  }

  getAllDistinctKeys() {
    Map<String, Purchase> distinctMap = {};
    for (var purchase in _items) {
      distinctMap.putIfAbsent(purchase.billId, () => purchase);
    }

    return distinctMap.values.toList();
  }

  List<Purchase> getPurchaseByBillId(String billId) {
    return _items.where((purchase) => purchase.billId == billId).toList();
  }

  double sumPurchasesByBillId(List<Purchase> purchases) {
    double total = 0.0;
    purchases.forEach(
      (purc) {
        total += purc.value;
      },
    );
    return total;
  }

  double sumPurchasesNotPaidByBillId(List<Purchase> purchases) {
    double total = 0.0;
    purchases.forEach(
      (purc) {
        if (!purc.paid) total += purc.value;
      },
    );
    return total;
  }

  int countPurchasesPaidByBillId(List<Purchase> purchases) {
    return purchases.where((purchase) => purchase.paid).length;
  }

  Future<void> savePurchase(Map<String, Object> data) async {
    bool hasId = data['id'] != null;

    final purc = Purchase(
        id: hasId ? data['id'] as String : Random().nextDouble().toString(),
        value: double.parse(data['value'].toString()),
        description: data['description'] as String,
        date: DateTime.parse(data['date'].toString()),
        installmentsQuantity:
            int.parse(data['installmentsQuantity'].toString()),
        creditCardId: data['creditCardId'] as String,
        categoryId: data['categoryId'] as String,
        paid: data['paid'] as bool,
        billId: data['billId'] as String);

    if (purc.billId == '-1') purc.billId = Uuid().v4();

    if (purc.installmentsQuantity > 1) {
      double valuePerMounth = purc.value / purc.installmentsQuantity;
      int orignalInstallmentsQuantity = purc.installmentsQuantity;
      DateTime originalDate = purc.date;
      for (int i = 0; i < orignalInstallmentsQuantity; i++) {
        print(i.toString() + '>> ' + purc.date.toString());
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

  Future<void> insertOrUpdate(Purchase purc, bool hasId) async {
    if (hasId)
      return await updatePurchase(purc);
    else
      return await addPurchase(purc);
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
            "billId": purc.billId,
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
            "billId": purc.billId,
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
            billId: purc.billId),
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
