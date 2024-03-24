import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_financial_life/exceptions/http_exception.dart';
import 'package:my_financial_life/models/credit_cart.dart';
import 'package:my_financial_life/models/earning.dart';
import 'package:my_financial_life/utils/constants.dart';

class EarningService with ChangeNotifier {
  List<Earning> _items = [];
  List<Earning> get items => [..._items];
  int get itemsCount {
    return _items.length;
  }

  double sum() {
    double total = 0.0;
    _items.forEach((ernItem) {
      total += ernItem.value;
    });
    return total;
  }

  Future<void> loadEarnings() async {
    _items.clear();

    final response =
        await http.get(Uri.parse('${Constants.EARNING_BASE_URL}.json'));

    if (response.body == 'null') return;

    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((credCardId, credCardData) {
      _items.add(
        Earning(
          id: credCardId,
          value: credCardData['value'],
          date: DateTime.parse(credCardData['date']),
          description: credCardData['description'],
          observation: credCardData['observation'],
          categoryId: credCardData['categoryId'],
          profit: credCardData['profit'],
        ),
      );
    });
    notifyListeners();
  }

  Future<void> saveEarning(Map<String, Object> data) {
    bool hasId = data['id'] != null;
    print('>>' + (data['profit'].toString() == '').toString() + '>${data['profit'].toString().isEmpty}<');
    final earning = Earning(
        id: hasId ? data['id'] as String : Random().nextDouble().toString(),
        value: double.parse(data['value'].toString()),
        date: DateTime.parse(data['date'].toString()),
        description: data['description'] as String,
        observation: data['observation'] as String,
        categoryId: data['categoryId'] as String,
        profit: double.parse(data['profit'].toString().isEmpty ? '0' : data['profit'].toString()),
        );

    if (hasId)
      return updateEarning(earning);
    else
      return addEarning(earning);
  }

  Future<void> updateEarning(Earning earning) async {
    int index = _items.indexWhere((p) => p.id == earning.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse(
            '${Constants.EARNING_BASE_URL}/${earning.id}.json'),
        body: jsonEncode(
          {
            "value": earning.value,
            "date": earning.date.toIso8601String(),
            "description": earning.description,
            "observation": earning.observation,
            "categoryId": earning.categoryId,
            "profit": earning.profit,
          },
        ),
      );

      _items[index] = earning;
      notifyListeners();
    }
  }

  Future<void> addEarning(Earning earning) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${Constants.EARNING_BASE_URL}.json'), // No firebase a URL deve terminar com .json
        body: jsonEncode(
          {
            "value": earning.value,
            "date": earning.date.toIso8601String(),
            "description": earning.description,
            "observation": earning.observation,
            "categoryId": earning.categoryId,
            "profit": earning.profit,
          },
        ),
      );

      final id = jsonDecode(response.body)['name'];
      _items.add(
        Earning(
          id: id,
          value: earning.value,
          date: earning.date,
          description: earning.description,
          observation: earning.observation,
          categoryId: earning.categoryId,
          profit: earning.profit,
        ),
      );
      notifyListeners(); 
    } catch (error) {
      print(error);
    }
  }

  Future<void> removeEarning(Earning earning) async {
    int index = _items.indexWhere((p) => p.id == earning.id);
    if (index >= 0) {
      final earning = _items[index];
      _items.remove(earning);
      notifyListeners();

      final response = await http.delete(
        Uri.parse(
            '${Constants.EARNING_BASE_URL}/${earning.id}.json'),
      );

      if (response.statusCode >= 400) {
        _items.insert(index, earning);
        notifyListeners();
        throw HttpException(
          msg: 'Não foi possível excluir o ganho',
          statusCode: response.statusCode,
        );
      }
    }
  }
}
