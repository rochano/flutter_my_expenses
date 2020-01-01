import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transactions.dart';
import '../widgets/transaction_item.dart';
import '../screens/edit_transaction_screen.dart';

class TransactionScreen extends StatelessWidget {
  static const routName = '/transactions';

  Future<void> _refreshTransaction(BuildContext context) async {
    await Provider.of<Transactions>(context, listen: false)
        .fetchAndSetTransactions(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Expenses'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditTransactionScreen.routName);
            },
          )
        ],
      ),
      body: FutureBuilder(
          future: _refreshTransaction(context),
          builder: (ctx, snapshot) => snapshot.connectionState ==
                  ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: () => _refreshTransaction(context),
                  child: Consumer<Transactions>(
                    builder: (ctx, trsData, _) => Padding(
                      padding: EdgeInsets.all(8),
                      child: ListView.builder(
                        itemCount: trsData.items.length,
                        itemBuilder: (_, i) => Column(
                          children: [
                            TransactionItem(
                                trsData.items[i].id, 
                                trsData.items[i].title,
                                trsData.items[i].amount,
                                trsData.items[i].date),
                            Divider(),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
    );
  }
}
