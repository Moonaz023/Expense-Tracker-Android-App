import 'package:ExpenseTracker/yearly_report.dart';
import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'calendar_page.dart';
import 'add_income2.dart';
import 'all_transactions.dart';
import 'dashboard.dart';
import 'liabilities_entry_page.dart';
import 'database_helper.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double income = 0;
  double expense = 0;
  double balance = 0;

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase();
  }

  Future<void> fetchDataFromDatabase() async {
    final databaseHelper = DatabaseHelper();
    final transactions = await databaseHelper.getTransactions();

    // Get the current month and year
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // Filter transactions for the current month and year
    final currentMonthTransactions = transactions.where((transaction) {
      final transactionDate = DateTime.parse(transaction['date']);
      return transactionDate.month == currentMonth && transactionDate.year == currentYear;
    }).toList();

    double income = 0;
    double expense = 0;

    for (var transaction in currentMonthTransactions) {
      final amount = transaction['amount'];
      if (transaction['type'] == 'Income') {
        income += amount;
      } else if (transaction['type'] == 'Expense') {
        expense += amount;
      }
    }

    setState(() {
      this.income = income;
      this.expense = expense;
      this.balance = income - expense;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarPage()),
              );
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Dashboard(income: income, expense: expense, balance: balance),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddIncomePage()),
                  ).then((value) {
                    // When you return from AddIncomePage, refresh the data
                    fetchDataFromDatabase();
                  });
                },
                child: SizedBox(
                  height: 50,
                  child: Center(child: Text('Add Transaction')),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LiabilitiesEntryPage()),
                  ).then((value) {
                    // When you return from AllTransactions, refresh the data
                    fetchDataFromDatabase();
                  });
                },
                child: SizedBox(
                  height: 50,
                  child: Center(child: Text('Add Liabilities')),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllTransactions()),
                  ).then((value) {
                    // When you return from AllTransactions, refresh the data
                    fetchDataFromDatabase();
                  });
                },
                child: SizedBox(
                  height: 50,
                  child: Center(child: Text('All Transaction')),
                ),
              ),

              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => YearlyReportPage()),
                  );
                },
                child: SizedBox(
                  height: 50,
                  child: Center(child: Text('Yearly Report')),
                ),
              ),



            ],
          ),
        ),
      ),
      drawer: Sidebar(),
    );
  }
}
