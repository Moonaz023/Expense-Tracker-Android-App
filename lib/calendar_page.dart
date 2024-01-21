import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database_helper.dart';
import 'edit_transaction.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final dbHelper = DatabaseHelper();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  DateTime? _highlightedDay;
  Map<String, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() async {
    final allTransactions = await dbHelper.getTransactions();

    // Clear the events for the selected day
    _events.removeWhere((key, value) => key == _highlightedDay.toString().split(' ')[0]);

    for (final transaction in allTransactions) {
      final date = transaction['date'];
      final transactionInfo = transaction;

      _events.update(date, (value) => [...value, transactionInfo], ifAbsent: () => [transactionInfo]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Page'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TableCalendar(
              firstDay: DateTime.utc(2022, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              eventLoader: (date) => [],
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _highlightedDay = selectedDay;
                  _loadEvents(); // Reload data for the selected day
                });
              },
            ),
            if (_highlightedDay != null)
              Text(
                'Transactions for ${_highlightedDay.toString().split(' ')[0]}:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ..._getEventsForDay(_highlightedDay).map(
                  (transaction) {
                return ListTile(
                  title: Text('Type: ${transaction['type']}, Amount: ${transaction['amount']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category: ${transaction['category']}'),
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
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime? day) {
    if (day == null) {
      return [];
    }
    final matchingEvents = _events[day.toString().split(' ')[0]];
    if (matchingEvents != null) {
      return matchingEvents;
    }
    return [];
  }

  void editData(Map<String, dynamic> item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionPage(
          data: item,
          onDataEdited: () async {
            await Future.delayed(const Duration(milliseconds: 500)); // Add a delay
            _loadEvents();
            setState(() {}); // Force a rebuild of the page to display the updated data
             _loadEvents();
          },
        ),
      ),
    );
  }


  void deleteData(int id) async {
    await dbHelper.deleteTransaction(id);
    _loadEvents();
  }

  Future<void> confirmDelete(int id) async {
    showDialog<void>(
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
}
