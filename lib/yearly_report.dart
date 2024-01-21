import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'database_helper.dart';

class YearlyReportPage extends StatefulWidget {
  @override
  _YearlyReportPageState createState() => _YearlyReportPageState();
}

class _YearlyReportPageState extends State<YearlyReportPage> {
  List<String>? categories;
  List<double>? categoryAmounts;
  List<Color>? categoryColors; // List to store colors for each category

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase();
  }

  Future<void> fetchDataFromDatabase() async {
    DatabaseHelper databaseHelper = DatabaseHelper();
    List<Map<String, dynamic>> categoryData =
    await databaseHelper.getCategoriesAndAmounts();
    setState(() {
      // Filter out categories with zero amounts
      categoryData.removeWhere((data) => data['amount'] == 0);

      categories =
      List<String>.from(categoryData.map((data) => data['category']));
      categoryAmounts =
      List<double>.from(categoryData.map((data) => data['amount']));
      categoryColors = List.generate(
        categories!.length,
            (index) => getRandomColor(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (categories == null || categoryAmounts == null || categoryColors == null) {
      return Center(child: CircularProgressIndicator());
    }

    double totalExpense =
    categoryAmounts!.reduce((value, element) => value + element);

    final List<double> percentages =
    categoryAmounts!.map((amount) => (amount / totalExpense) * 100).toList();

    final List<PieChartSectionData> pieChartData = List.generate(
      categories!.length,
          (index) {
        return PieChartSectionData(
          value: percentages[index],
          color: categoryColors![index],
          title: '',
          radius: 100,
          showTitle: false,
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Yearly Reports'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              'Yearly Income and Expense Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Container(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: pieChartData,
                  centerSpaceRadius: 0,
                  sectionsSpace: 1,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Category Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: categories!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 16,
                              height: 16,
                              color: categoryColors![index],
                            ),
                            SizedBox(width: 8),
                            Text(
                              categories![index],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          '${percentages[index].toStringAsFixed(2)}%',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: Text('Amount: \$${categoryAmounts![index]}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(255, random.nextInt(256), random.nextInt(256),
        random.nextInt(256));
  }
}

void main() => runApp(MaterialApp(home: YearlyReportPage()));