import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_expenses/screens/edit_transaction_screen.dart';
import '../providers/transactions.dart';
import 'package:provider/provider.dart';

class TransactionItem extends StatelessWidget {
  final String id;
  final String title;
  final double amount;
  final DateTime date;

  TransactionItem(this.id, this.title, this.amount, this.date);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: FittedBox(child: Text('\u0e3f${amount.toStringAsFixed(2)}')),
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.title,
      ),
      subtitle: Text('${DateFormat.yMMMd().format(date)}'),
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
