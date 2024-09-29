import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart'; // Ensure you have the correct path to your DatabaseHelper
import 'package:intl/intl.dart';

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final dbHelper = DatabaseHelper();
  double totalBudget = 0.0;
  String? selectedCategory;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  List<String> categoryList = [];
  Map<String, double> categoryAmounts = {};
  bool showChart = false;

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

  void _addBudget(double amount) {
    setState(() {
      totalBudget += amount;
    });
  }

  void _addCategoryAmount() async {
    final String amountStr = amountController.text;
    final String category = selectedCategory ?? "";
    final String note = noteController.text;

    if (amountStr.isNotEmpty && category.isNotEmpty && note.isNotEmpty) {
      final double amount = double.tryParse(amountStr) ?? 0.0;

      // Insert into the database
      final insertedId = await dbHelper.insertTransaction({
        'amount': amount,
        'category': category,
        'note': note,
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      });
      print('Category amount inserted with ID: $insertedId');

      // Update the category amounts
      setState(() {
        categoryAmounts[category] = (categoryAmounts[category] ?? 0) + amount;
        amountController.clear();
        noteController.clear();
        selectedCategory = null;
        showChart = true; // Show chart after adding amount
      });
    }
  }

  void _showAddBudgetDialog() {
    double amount = 0.0;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Budget'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              amount = double.tryParse(value) ?? 0.0;
            },
            decoration: InputDecoration(hintText: "Enter budget amount"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (amount > 0) {
                  _addBudget(amount);
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryAmountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Category Amount'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,  // Ensure the dialog is not too large
              children: [
                DropdownButtonFormField<String>(
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
                SizedBox(height: 12.0),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12.0),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: 'Note',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addCategoryAmount();  // Make sure the category exists
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }


  List<BarChartGroupData> getBarChartGroups() {
    List<BarChartGroupData> groups = [];
    int index = 0;

    categoryAmounts.forEach((category, amount) {
      groups.add(BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: Colors.primaries[index % Colors.primaries.length],
            width: 20,
          ),
        ],
      ));
    });

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Budget: \$${totalBudget.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            if (showChart && categoryAmounts.isNotEmpty)
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    barGroups: getBarChartGroups(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 38,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              categoryAmounts.keys.elementAt(value.toInt()),
                              style: TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _showAddBudgetDialog,
                  child: Text('Add Budget'),
                ),
                ElevatedButton(
                  onPressed: _showAddCategoryAmountDialog,
                  child: Text('Add Category Amount'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
