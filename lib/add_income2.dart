import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

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
    final DateTime date = selectedDate ?? DateTime.now(); // Ensure selectedDate is not null
    final String mode = modeController.text;
    final String note = noteController.text;

    if (amount.isNotEmpty &&
        category.isNotEmpty &&
        mode.isNotEmpty &&
        note.isNotEmpty &&
        transactionType != null) {
      final insertedId = await dbHelper.insertTransaction({
        'type': transactionType!,
        'amount': amount,
        'category': category,
        'date': date, // Store DateTime object directly (it will be converted to Unix timestamp in insertTransaction)
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
        selectedDate = null;
      });
    }
  }

  DateTime? selectedDate;

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: transactionType,
                onChanged: (String? value) {
                  setState(() {
                    transactionType = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Transaction Type',
                  border: OutlineInputBorder(),
                ),
                items: <String>['Income', 'Expense'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
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
              SizedBox(height: 16.0),
              TextField(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null && pickedDate != selectedDate) {
                    setState(() {
                      selectedDate = pickedDate;
                      dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: modeController,
                decoration: InputDecoration(
                  labelText: 'Mode of Payment',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: addTransaction,
                style: ElevatedButton.styleFrom(
                  //default
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Add Transaction',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
