import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../providers/transaction.dart';
import '../providers/transactions.dart';
import '../widgets/image_input.dart';

class EditTransactionScreen extends StatefulWidget {
  static const routName = '/edit-transaction';

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _form = GlobalKey<FormState>();
  var _priceController = TextEditingController();
  var _quantityController = TextEditingController();
  var _amountController = TextEditingController();
  DateTime _selectedDate;
  var _dateController = TextEditingController();
  File _image;
  String _imageUrl;

  var _editedTransaction = Transaction(
    id: null,
    title: '',
    price: 0,
    quantity: 0,
    amount: 0,
    date: null,
  );
  var _initValues = {
    'title': '',
    'price': '',
    'quantity': '',
    'amount': '',
    'image': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final trsId = ModalRoute.of(context).settings.arguments as String;
      if (trsId != null) {
        _editedTransaction =
            Provider.of<Transactions>(context, listen: false).findById(trsId);
        _initValues = {
          'title': _editedTransaction.title,
          'price': _editedTransaction.price.toString(),
          'quantity': _editedTransaction.quantity.toString(),
          'amount': _editedTransaction.amount.toString(),
          'image': _editedTransaction.image,
        };
        _priceController.text = _editedTransaction.price.toString();
        _quantityController.text = _editedTransaction.quantity.toString();
        _amountController.text = _editedTransaction.amount.toString();
        setState(() {
          _selectedDate = _editedTransaction.date;
        });
        if (_initValues['image'] != null && _initValues['image'].isNotEmpty) {
          var ref = FirebaseStorage.instance.ref().child(_initValues['image']);
          ref.getDownloadURL().then((loc) => setState(() => _imageUrl = loc));
        }
      } else {
        setState(() {
          _selectedDate = DateTime.now();
        });
        _quantityController.text = '1';
      }
      _dateController.text = DateFormat.yMMMd().format(_selectedDate);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    _editedTransaction.pickImage = _initValues['image'];

    if (_image != null) {
      String fileName =
          _initValues['image'] != null && _initValues['image'].isNotEmpty
              ? _initValues['image']
              : path.basename(_image.path);
      StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName);
      firebaseStorageRef.putFile(_image);
      _editedTransaction.pickImage = fileName;
      print("fileName: " + fileName);
    }

    if (_editedTransaction.id != null) {
      await Provider.of<Transactions>(context, listen: false)
          .updateTransaction(_editedTransaction.id, _editedTransaction);
    } else {
      try {
        await Provider.of<Transactions>(context, listen: false)
            .addTransaction(_editedTransaction);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return null;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
      _dateController.text = DateFormat.yMMMd().format(_selectedDate);
    });
  }

  void _selectImage(File pickedImage) {
    _image = pickedImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Transaction'),
        actions: <Widget>[
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 2,
                ))
              : IconButton(
                  icon: Icon(Icons.save),
                  onPressed: _saveForm,
                )
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _form,
            child: ListView(
              children: <Widget>[
                ImageInput(_initValues, _imageUrl, _selectImage),
                TextFormField(
                  initialValue: _initValues['title'],
                  decoration: InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please provide a value.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _editedTransaction = Transaction(
                        id: _editedTransaction.id,
                        title: value,
                        price: _editedTransaction.price,
                        quantity: _editedTransaction.quantity,
                        amount: _editedTransaction.amount,
                        date: _selectedDate);
                  },
                ),
                TextFormField(
                  //initialValue: _initValues['price'],
                  decoration: InputDecoration(labelText: 'Price(\u0e3f)'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.numberWithOptions(),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please eneter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number.';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Please enter a number greater than zero.';
                    }
                    return null;
                  },
                  controller: _priceController,
                  onChanged: (value) {
                    double amount = value.isEmpty
                        ? 0
                        : double.parse(value) *
                            double.parse(_quantityController.text);
                    _amountController.text = amount.toStringAsFixed(2);
                  },
                  onSaved: (value) {
                    _editedTransaction = Transaction(
                        id: _editedTransaction.id,
                        title: _editedTransaction.title,
                        price: double.parse(value),
                        quantity: _editedTransaction.quantity,
                        amount: _editedTransaction.amount,
                        date: _selectedDate);
                  },
                ),
                TextFormField(
                  //initialValue: _initValues['quantity'],
                  decoration: InputDecoration(labelText: 'Quantity'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please eneter a quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number.';
                    }
                    if (int.parse(value) <= 0) {
                      return 'Please enter a number greater than zero.';
                    }
                    return null;
                  },
                  controller: _quantityController,
                  onChanged: (value) {
                    double amount = value.isEmpty
                        ? 0
                        : int.parse(value) *
                            double.parse(_priceController.text);
                    _amountController.text = amount.toStringAsFixed(2);
                  },
                  onSaved: (value) {
                    _editedTransaction = Transaction(
                        id: _editedTransaction.id,
                        title: _editedTransaction.title,
                        price: _editedTransaction.price,
                        quantity: int.parse(value),
                        amount: _editedTransaction.amount,
                        date: _selectedDate);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Amount(\u0e3f)'),
                  enabled: false,
                  controller: _amountController,
                  onSaved: (value) {
                    _editedTransaction = Transaction(
                        id: _editedTransaction.id,
                        title: _editedTransaction.title,
                        price: _editedTransaction.price,
                        quantity: _editedTransaction.quantity,
                        amount: double.parse(value),
                        date: _selectedDate);
                  },
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Date'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please select a date.';
                            }
                            return null;
                          },
                          enabled: false,
                          controller: _dateController,
                          onSaved: (value) {
                            _editedTransaction = Transaction(
                                id: _editedTransaction.id,
                                title: _editedTransaction.title,
                                price: _editedTransaction.price,
                                quantity: _editedTransaction.quantity,
                                amount: _editedTransaction.amount,
                                date: _selectedDate);
                          },
                        ),
                      ),
                      FlatButton(
                        textColor: Theme.of(context).primaryColor,
                        child: Icon(Icons.date_range),
                        onPressed: _presentDatePicker,
                      )
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
