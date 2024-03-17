import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_financial_life/exceptions/http_exception.dart';
import 'package:my_financial_life/models/credit_cart.dart';
import 'package:my_financial_life/utils/constants.dart';

class CreditCardService with ChangeNotifier {
  List<CreditCard> _items = [];
  List<CreditCard> get items => [..._items];
  int get itemsCount {
    return _items.length;
  }

  double sumLimits() {
    double total = 0.0;
    _items.forEach((credItem) {
      total += credItem.limit;
    });
    return total;
  }

  Future<void> loadCreditCards() async {
    _items.clear();

    final response =
        await http.get(Uri.parse('${Constants.CREDIT_CARD_BASE_URL}.json'));

    if (response.body == 'null') return;

    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((credCardId, credCardData) {
      _items.add(
        CreditCard(
          id: credCardId,
          name: credCardData['name'],
          limit: credCardData['limit'],
          color: Color(credCardData['color']),
        ),
      );
    });
    notifyListeners();
  }

  Future<void> saveCreditCard(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final creditCard = CreditCard(
        id: hasId ? data['id'] as String : Random().nextDouble().toString(),
        name: data['name'] as String,
        limit: data['limit'] as double,
        color: data['color'] as Color);

    if (hasId)
      return updateCreditCard(creditCard);
    else
      return addCreditCard(creditCard);
  }

  Future<void> updateCreditCard(CreditCard creditCard) async {
    int index = _items.indexWhere((p) => p.id == creditCard.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse(
            '${Constants.CREDIT_CARD_BASE_URL}/${creditCard.id}.json'), // No firebase a URL deve terminar com .json
        body: jsonEncode(
          {
            "name": creditCard.name,
            "limit": creditCard.limit,
            "color": creditCard.color.value,
          },
        ),
      );

      _items[index] = creditCard;
      notifyListeners();
    }
  }

  Future<void> addCreditCard(CreditCard creditCard) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${Constants.CREDIT_CARD_BASE_URL}.json'), // No firebase a URL deve terminar com .json
        body: jsonEncode(
          {
            "name": creditCard.name,
            "limit": creditCard.limit,
            "color": creditCard.color.value,
          },
        ),
      );

      final id = jsonDecode(response.body)['name'];
      _items.add(
        CreditCard(
          id: id,
          name: creditCard.name,
          limit: creditCard.limit,
          color: creditCard.color,
        ),
      );
      notifyListeners(); // Chama o notificador sempre que houver uma mudança na lista
    } catch (error) {
      print(error);
    }
  }

  Future<void> removeCreditCard(CreditCard creditCard) async {
    int index = _items.indexWhere((p) => p.id == creditCard.id);
    if (index >= 0) {
      final creditCard = _items[index];
      _items.remove(creditCard);
      notifyListeners();

      final response = await http.delete(
        Uri.parse(
            '${Constants.CREDIT_CARD_BASE_URL}/${creditCard.id}.json'), // No firebase a URL deve terminar com .json
      );

      if (response.statusCode >= 400) {
        _items.insert(index, creditCard);
        notifyListeners();
        throw HttpException(
          msg: 'Não foi possível excluir o produto',
          statusCode: response.statusCode,
        );
      }
    }
  }
}
