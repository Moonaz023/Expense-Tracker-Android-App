import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'liabilities_list_page.dart';

class LiabilitiesEntryPage extends StatefulWidget {
  @override
  _LiabilitiesEntryPageState createState() => _LiabilitiesEntryPageState();
}

class _LiabilitiesEntryPageState extends State<LiabilitiesEntryPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController obligationsController = TextEditingController();
  final TextEditingController repaymentDateController = TextEditingController();
  final TextEditingController interestController = TextEditingController();

  // Function to clear text controllers
  void _clearForm() {
    amountController.clear();
    obligationsController.clear();
    repaymentDateController.clear();
    interestController.clear();
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        repaymentDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Liability'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount'),
              ),
              TextField(
                controller: obligationsController,
                decoration: InputDecoration(labelText: 'Obligations'),
              ),
              TextField(
                controller: repaymentDateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(labelText: 'Repayment Date'),
              ),
              TextField(
                controller: interestController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Interest Percentage'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Get values from controllers and add the liability to the db
                  double amount = double.tryParse(amountController.text) ?? 0;
                  String obligations = obligationsController.text;
                  String repaymentDate = repaymentDateController.text;
                  double interestPercentage = double.tryParse(interestController.text) ?? 0;

                  // Add to database
                  DatabaseHelper().insertLiability(amount, obligations, repaymentDate, interestPercentage);

                  // Clear the form
                  _clearForm();
                },
                child: Text('Add Liability'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LiabilitiesListPage(updateExpenseCallback: (double ) {  },)),
                  );
                },
                child: Text('See All Liabilities'),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
