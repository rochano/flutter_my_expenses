import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './transaction.dart';
import '../exceptions/http_exception.dart';

class Transactions with ChangeNotifier {
  List<Transaction> _items = [];
  final String authToken;
  final String userId;

  Transactions(this.authToken, this.userId, this._items);

  List<Transaction> get items {
    return [..._items];
  }

  Future<void> filteredByDate(DateTime startDate, DateTime lastDate) {
    _items = _items
        .where((trs) =>
            trs.date.isAfter(startDate) &&
            trs.date.isBefore(lastDate.add(Duration(days: 1))))
        .toList();
    notifyListeners();
  }

  Transaction findById(String id) {
    return _items.firstWhere((trs) => trs.id == id);
  }

  Future<void> fetchAndSetTransactions() async {
    final filterString = 'orderBy="createdBy"&equalTo="$userId"';
    var url = 'https://micro-eye-252307.firebaseio.com/transactions.json?auth=$authToken&$filterString';
    //print(url);
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
    final url = 'https://micro-eye-252307.firebaseio.com/transactions.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': transaction.title,
          'price': transaction.price,
          'quantity': transaction.quantity,
          'amount': transaction.amount,
          'date': transaction.date.toIso8601String(),
          'image': transaction.image,
          'createdBy': userId
        }),
      );
      final newTransaction = Transaction(
        title: transaction.title,
        price: transaction.price,
        quantity: transaction.quantity,
        amount: transaction.amount,
        date: transaction.date,
        image: transaction.image,
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
          'https://micro-eye-252307.firebaseio.com/transactions/$id.json?auth=$authToken';
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

  Future<void> deleteTransaction(String id, String image) async {
    final url = 'https://micro-eye-252307.firebaseio.com/transactions/$id.json?auth=$authToken';
    final trsIndex = _items.indexWhere((trs) => trs.id == id);
    var transaction = _items[trsIndex];
    _items.removeAt(trsIndex);
    notifyListeners();
    var response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(trsIndex, transaction);
      notifyListeners();
      throw HttpException('Could not delete transaction.');
    }
    if (image != null && image.isNotEmpty) {
      StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(image);
      await firebaseStorageRef.delete();
    }
    transaction = null;
  }
}
