import 'package:flutter/material.dart';

class Transaction with ChangeNotifier {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final double amount;

  Transaction({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.quantity,
    @required this.amount
  });
}
