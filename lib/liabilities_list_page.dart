import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class LiabilitiesListPage extends StatefulWidget {
  final Function(double) updateExpenseCallback;

  LiabilitiesListPage({required this.updateExpenseCallback});

  @override
  _LiabilitiesListPageState createState() => _LiabilitiesListPageState();
}

class _LiabilitiesListPageState extends State<LiabilitiesListPage> {
  late Future<List<Map<String, dynamic>>> _liabilities;

  @override
  void initState() {
    super.initState();
    _liabilities = DatabaseHelper().getLiabilities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liabilities List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _liabilities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No liabilities found.'));
          } else {
            List<Map<String, dynamic>> liabilities = snapshot.data!;
            return ListView.builder(
              itemCount: liabilities.length,
              itemBuilder: (context, index) {
                var liability = liabilities[index];
                double totalAmount =
                    liability['amount'] + (liability['amount'] * (liability['interestPercentage'] / 100));
                return ListTile(
                  title: Text('Total Amount to pay: \$${totalAmount.toStringAsFixed(2)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Amount: \$${liability['amount']}'),
                      Text('Obligations: ${liability['obligations']}'),
                      Text('Repayment Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(liability['repaymentDate']))}'),
                      Text('Interest Percentage: ${liability['interestPercentage']}%'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () async {
                          double paidAmount = await DatabaseHelper().deleteLiability(liability['id']);
                          setState(() {
                            _liabilities = DatabaseHelper().getLiabilities();
                          });
                          widget.updateExpenseCallback(paidAmount);
                        },
                        child: Text('Paid Off'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
