import 'package:flutter/material.dart';
import 'database_helper.dart';

class AddIncomePage extends StatefulWidget {
  @override
  _AddIncomePageState createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final dbHelper = DatabaseHelper();
  String? transactionType;
  final TextEditingController amountController = TextEditingController();
  String? selectedCategory;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController modeController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  List<String> categoryList = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    final List<Map<String, dynamic>> categories = await dbHelper.getCategories();
    setState(() {
      categoryList = categories.map((category) => category['category'].toString()).toList();
    });
  }

  void addTransaction() async {
    final String amount = amountController.text;
    final String category = selectedCategory ?? "";
    final String date = dateController.text;
    final String mode = modeController.text;
    final String note = noteController.text;

    if (amount.isNotEmpty &&
        category.isNotEmpty &&
        date.isNotEmpty &&
        mode.isNotEmpty &&
        note.isNotEmpty &&
        transactionType != null) {
      final insertedId = await dbHelper.insertTransaction({
        'type': transactionType!,
        'amount': amount,
        'category': category,
        'date': date,
        'mode': mode,
        'note': note,
      });
      print('Transaction inserted with ID: $insertedId');

      amountController.clear();
      dateController.clear();
      modeController.clear();
      noteController.clear();
      setState(() {
        selectedCategory = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Income/Expense'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: transactionType,
                onChanged: (String? value) {
                  setState(() {
                    transactionType = value;
                  });
                },
                hint: Text('Transaction Type'),
                items: <String>['Income', 'Expense'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12.0),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButton<String>(
                  value: selectedCategory,
                  onChanged: (String? value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  hint: Text('Select a Category'),
                  items: categoryList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: modeController,
                decoration: InputDecoration(
                  labelText: 'Mode of Payment',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: addTransaction,
                child: Text('Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
