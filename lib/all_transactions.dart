import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'edit_transaction.dart';
import 'package:intl/intl.dart';

class AllTransactions extends StatefulWidget {
  @override
  _AllTransactionsState createState() => _AllTransactionsState();
}

class _AllTransactionsState extends State<AllTransactions> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> data = [];
  Map<String, List<Map<String, dynamic>>> groupedData = {};

  @override
  void initState() {
    super.initState();
    getDataFromDatabase();
  }

  void getDataFromDatabase() async {
    final dataList = await dbHelper.getTransactions();
    setState(() {
      data = dataList;
      groupedData = groupDataByMonth(data);
    });
  }

  Map<String, List<Map<String, dynamic>>> groupDataByMonth(List<Map<String, dynamic>> data) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    for (final transaction in data) {
      final date = DateTime.parse(transaction['date']);
      final formattedDate = DateFormat.yMMMM().format(date);

      if (groupedData.containsKey(formattedDate)) {
        groupedData[formattedDate]!.add(transaction);
      } else {
        groupedData[formattedDate] = [transaction];
      }
    }

    return groupedData;
  }

  void deleteData(int id) async {
    await dbHelper.deleteTransaction(id);
    getDataFromDatabase();
  }

  Future<void> confirmDelete(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Item'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this item?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                deleteData(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void editData(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionPage(
          data: item,
          onDataEdited: () {
            getDataFromDatabase();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Transactions'),
      ),
      body: ListView.builder(
        itemCount: groupedData.length,
        itemBuilder: (context, index) {
          final List<String> keys = groupedData.keys.toList();
          final String monthYear = keys[index];
          final List<Map<String, dynamic>> transactions = groupedData[monthYear]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  monthYear,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...transactions.map((transaction) {
                return ListTile(
                  title: Text('Type: ${transaction['type']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: ${transaction['amount']}'),
                      Text('Category: ${transaction['category']}'),
                      Text('Date: ${transaction['date']}'),
                      Text('Mode: ${transaction['mode']}'),
                      Text('Note: ${transaction['note']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          editData(transaction);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          confirmDelete(transaction['id']);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
