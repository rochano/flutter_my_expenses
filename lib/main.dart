import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/transactions.dart';
import './screens/edit_transaction_screen.dart';
import './screens/transaction_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (ctx) => Transactions(),
      child: MaterialApp(
          title: 'My Expenses',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: TransactionScreen(),
          routes: {
            TransactionScreen.routName: (ctx) => TransactionScreen(),
            EditTransactionScreen.routName: (ctx) => EditTransactionScreen(),
          },
        ),
    );
  }
}
