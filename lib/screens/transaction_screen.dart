import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

import '../providers/transactions.dart';
import '../widgets/transaction_item.dart';
import '../screens/edit_transaction_screen.dart';

enum FilterOptions {
  DateRange,
  All,
}

class TransactionScreen extends StatefulWidget {
  static const routName = '/transactions';

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  DateTime _filteredFirstDate;
  DateTime _filteredLastDate;

  Future<void> _refreshTransaction(BuildContext context) async {
    await Provider.of<Transactions>(context, listen: false)
        .fetchAndSetTransactions(true);

    if (_filteredFirstDate != null && _filteredLastDate != null) {
      await Provider.of<Transactions>(context, listen: false)
          .filteredByDate(_filteredFirstDate, _filteredLastDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Expenses'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) async {
              if (selectedValue == FilterOptions.DateRange) {
                final List<DateTime> picked =
                    await DateRangePicker.showDatePicker(
                        context: context,
                        initialFirstDate: _filteredFirstDate != null
                            ? _filteredFirstDate
                            : DateTime(2020),
                        initialLastDate: _filteredLastDate != null
                            ? _filteredLastDate
                            : DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now());
                if (picked != null) {
                  print(picked);
                  if (picked.length == 2) {
                    setState(() {
                      _filteredFirstDate = picked[0];
                      _filteredLastDate = picked[1];
                    });
                  } else if (picked.length == 1) {
                    setState(() {
                      _filteredFirstDate = picked[0];
                      _filteredLastDate = picked[0];
                    });
                  }
                }
              } else if (selectedValue == FilterOptions.All) {
                setState(() {
                  _filteredFirstDate = null;
                  _filteredLastDate = null;
                });
              }
            },
            icon: Icon(Icons.settings),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Date Range'),
                value: FilterOptions.DateRange,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              )
            ],
          ),
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
          builder: (ctx, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
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
                                    trsData.items[i].date,
                                    trsData.items[i].image),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
    );
  }
}
