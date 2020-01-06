import 'package:flutter/material.dart';
import 'package:my_expenses/providers/auth.dart';
import 'package:my_expenses/screens/auth_screen.dart';
import 'package:provider/provider.dart';

import './providers/transactions.dart';
import './screens/edit_transaction_screen.dart';
import './screens/transaction_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Transactions>(
          builder: (ctx, auth, previousTransactions) => Transactions(
            auth.token,
            auth.userId,
            previousTransactions == null ? [] : previousTransactions.items,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'My Expenses',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: auth.isAuth
              ? TransactionScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? CircularProgressIndicator()
                          : AuthScreen(),
                ),
          routes: {
            TransactionScreen.routName: (ctx) => TransactionScreen(),
            EditTransactionScreen.routName: (ctx) => EditTransactionScreen(),
          },
        ),
      ),
    );
  }
}
