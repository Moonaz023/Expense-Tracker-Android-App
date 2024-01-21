import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';


class Dashboard extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;

  Dashboard({
    required this.income,
    required this.expense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    // Format the current date to get the month name
    final now = DateTime.now();
    //final currentMonthName = DateFormat.MMMM().format(now);
    final currentMonthYear = DateFormat.yMMM().format(now);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              currentMonthYear,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: Container(
              width: 200,
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.red,
                      value: expense,
                      title: '\$${expense.toStringAsFixed(2)}',
                    ),
                    PieChartSectionData(
                      color: Colors.green,
                      value: income,
                      title: '\$${income.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Income', style: TextStyle(color: Colors.green,fontSize: 16)),
                  Text('\$${income.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Expense', style: TextStyle(color: Colors.red,fontSize: 16)),
                  Text('\$${expense.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Balance', style: TextStyle(color: Colors.green,fontSize: 16)),
                  Text('\$${balance.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
