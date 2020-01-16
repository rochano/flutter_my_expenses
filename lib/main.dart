import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './screens/auth_screen.dart';
import './providers/transactions.dart';
import './screens/edit_transaction_screen.dart';
import './screens/transaction_screen.dart';
import './screens/login_screen.dart';

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
                          : LoginScreen(),
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
