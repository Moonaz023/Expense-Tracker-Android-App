import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

class BudgetsPage extends StatefulWidget {
  @override
  _BudgetsPageState createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _budgets = [];
  Map<String, double> _categoryExpenses = {};
  String _currentMonth = '';

  @override
  void initState() {
    super.initState();
    _currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    _fetchBudgets();
    _fetchCategoryExpenses();
  }

  Future<void> _fetchBudgets() async {
    List<Map<String, dynamic>> budgets = await _databaseHelper.getBudgets();
    setState(() {
      _budgets = budgets;
    });
  }

  Future<void> _fetchCategoryExpenses() async {
    List<Map<String, dynamic>> transactions = await _databaseHelper.getTransactions();

    // Initialize the category expenses
    _categoryExpenses = {};

    for (var transaction in transactions) {
      String transactionDate = transaction['date'];
      if (transactionDate.startsWith(_currentMonth)) {
        String category = transaction['category']; // Assuming you have this in the transaction
        double amount = transaction['amount'];

        // Sum up expenses for each category
        if (_categoryExpenses.containsKey(category)) {
          _categoryExpenses[category] = (_categoryExpenses[category] ?? 0.0) + amount; // Ensure previous value is not null
        } else {
          _categoryExpenses[category] = amount;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budgets'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Current Month: $_currentMonth',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Budgets for $_currentMonth:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _budgets.length,
                itemBuilder: (context, index) {
                  var budget = _budgets[index];
                  String category = budget['category'];
                  double budgetAmount = budget['budgetAmount'];
                  double spentAmount = _categoryExpenses[category] ?? 0.0; // Default to 0 if null
                  double remainingAmount = budgetAmount - spentAmount; // Calculate remaining

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(category),
                      subtitle: Text('Budget: \$${budgetAmount.toStringAsFixed(2)}'),
                      trailing: Text(
                        'Remaining: \$${remainingAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: remainingAmount >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
