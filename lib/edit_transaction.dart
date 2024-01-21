import 'package:flutter/material.dart';
import 'database_helper.dart';

class EditTransactionPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onDataEdited;

  EditTransactionPage({required this.data, required this.onDataEdited});

  @override
  _EditTransactionPageState createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final dbHelper = DatabaseHelper();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController modeController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    typeController.text = widget.data['type'];
    amountController.text = widget.data['amount'].toString();
    categoryController.text = widget.data['category'];
    dateController.text = widget.data['date'];
    modeController.text = widget.data['mode'];
    noteController.text = widget.data['note'];
  }

  void saveChanges() async {
    final updatedData = {
      'type': typeController.text,
      'amount': double.parse(amountController.text),
      'category': categoryController.text,
      'date': dateController.text,
      'mode': modeController.text,
      'note': noteController.text,
    };

    await dbHelper.updateTransaction(widget.data['id'], updatedData);
    widget.onDataEdited(); // Notify the parent page that data has been edited
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(controller: typeController, decoration: InputDecoration(labelText: 'Type')),
              TextField(controller: amountController, decoration: InputDecoration(labelText: 'Amount')),
              TextField(controller: categoryController, decoration: InputDecoration(labelText: 'Category')),
              TextField(controller: dateController, decoration: InputDecoration(labelText: 'Date')),
              TextField(controller: modeController, decoration: InputDecoration(labelText: 'Mode')),
              TextField(controller: noteController, decoration: InputDecoration(labelText: 'Note')),
              ElevatedButton(
                onPressed: saveChanges,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
