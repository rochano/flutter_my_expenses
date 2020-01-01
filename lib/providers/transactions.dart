import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './transaction.dart';
import '../exceptions/http_exception.dart';

class Transactions with ChangeNotifier {
  List<Transaction> _items = [];

  //Transactions(this._items);

  List<Transaction> get items {
    return [..._items];
  }

  Transaction findById(String id) {
    return _items.firstWhere((trs) => trs.id == id);
  }

  Future<void> fetchAndSetTransactions([bool filterByUser = false]) async {
    final filterString = '';
    var url = 'https://micro-eye-252307.firebaseio.com/transactions.json';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<Transaction> loadedTransactions = [];
      extractedData.forEach((trsId, trsData) {
        loadedTransactions.add(Transaction(
          id: trsId,
          title: trsData['title'],
          price: trsData['price'],
          quantity: trsData['quantity'],
          amount: trsData['amount'],
          date: DateTime.parse(trsData['date']),
          image: trsData['image'],
        ));
      });
      _items = loadedTransactions;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    final url = 'https://micro-eye-252307.firebaseio.com/transactions.json';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': transaction.title,
          'price': transaction.price,
          'quantity': transaction.quantity,
          'amount': transaction.amount,
          'date': transaction.date.toIso8601String(),
          'image': transaction.image
        }),
      );
      final newTransaction = Transaction(
        title: transaction.title,
        price: transaction.price,
        quantity: transaction.quantity,
        amount: transaction.amount,
        date: transaction.date,
        id: json.decode(response.body)['name'],
      );
      _items.add(newTransaction);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateTransaction(String id, Transaction transaction) async {
    final trsIndex = _items.indexWhere((trs) => trs.id == id);
    if (trsIndex >= 0) {
      final url =
          'https://micro-eye-252307.firebaseio.com/transactions/$id.json';
      await http.patch(url,
          body: json.encode({
            'title': transaction.title,
            'price': transaction.price,
            'quantity': transaction.quantity,
            'amount': transaction.amount,
            'date': transaction.date.toIso8601String(),
            'image': transaction.image,
          }));
      _items[trsIndex] = transaction;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    final url = 'https://micro-eye-252307.firebaseio.com/transactions/$id.json';
    final trsIndex = _items.indexWhere((trs) => trs.id == id);
    var transaction = _items[trsIndex];
    _items.removeAt(trsIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(trsIndex, transaction);
      notifyListeners();
      throw HttpException('Could not delete transaction.');
    }
    transaction = null;
  }
}
