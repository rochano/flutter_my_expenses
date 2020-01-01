import 'package:flutter/material.dart';
import 'package:my_expenses/screens/edit_transaction_screen.dart';
import '../providers/transactions.dart';
import 'package:provider/provider.dart';

class TransactionItem extends StatelessWidget {
  final String id;
  final String title;

  TransactionItem(this.id, this.title);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(title),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditTransactionScreen.routName, arguments: id);
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                try {
                  await Provider.of<Transactions>(context, listen: false)
                      .deleteTransaction(id);
                } catch (error) {
                  scaffold.showSnackBar(
                    SnackBar(
                        content: Text(
                      'Delete failed!',
                      textAlign: TextAlign.center,
                    )),
                  );
                }
              },
              color: Theme.of(context).errorColor,
            )
          ],
        ),
      ),
    );
  }
}
