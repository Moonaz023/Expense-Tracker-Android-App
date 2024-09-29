import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

class MyBudget extends StatefulWidget {
  @override
  _MyBudgetState createState() => _MyBudgetState();
}

class _MyBudgetState extends State<MyBudget> {
  String? selectedCategory;
  double? budgetAmount;
  String? selectedMonth;
  List<String> categories = [];
  DatabaseHelper databaseHelper = DatabaseHelper();

  // Controllers to manage text fields
  TextEditingController monthController = TextEditingController();
  TextEditingController amountController = TextEditingController();  // Added controller for amount

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    List<Map<String, dynamic>> categoryData = await databaseHelper.getCategories();
    setState(() {
      categories = categoryData.map((data) => data['category'] as String).toList();
    });
  }

  Future<void> saveBudget() async {
    if (selectedCategory != null && budgetAmount != null && selectedMonth != null) {
      // Use the new insertOrUpdateBudget method
      await databaseHelper.insertOrUpdateBudget(selectedCategory!, budgetAmount!, selectedMonth!);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Budget set successfully!")));

      // Clear the form after saving the budget
      setState(() {
        selectedCategory = null;
        budgetAmount = null;
        selectedMonth = null;
        monthController.clear();   // Clear the month field
        amountController.clear();  // Clear the amount field
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set Budget")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              hint: Text("Select Category"),
              value: selectedCategory,
              onChanged: (value) => setState(() => selectedCategory = value),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: amountController,  // Link the controller to the amount field
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter Budget Amount'),
              onChanged: (value) => setState(() => budgetAmount = double.tryParse(value)),
            ),
            SizedBox(height: 10),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(labelText: 'Select Month'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedMonth = DateFormat('yyyy-MM').format(pickedDate);
                    monthController.text = selectedMonth!; // Update the text in the controller
                  });
                }
              },
              controller: monthController, // Use the controller to manage the text field
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveBudget,
              child: Text('Set Budget'),
            ),
          ],
        ),
      ),
    );
  }
}
