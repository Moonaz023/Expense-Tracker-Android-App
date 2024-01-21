import 'package:flutter/material.dart';
import 'developer.dart';
import 'add_category.dart';
import 'home.dart';
import 'liabilities_list_page.dart';
import 'calendar_page.dart';


class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 2,
            child: Container(
              height: 172,
              color: Colors.blue[900],
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/cover.jpeg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                ],
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Column(
              children: <Widget>[


                SizedBox(height: 6),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  },
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.home),
                        SizedBox(width: 8),
                        Text('Home'),
                      ],
                    ),
                  ),
                ),


                SizedBox(height: 6),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CalendarPage()),
                    );
                  },
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text('Calendar View'),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 6),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LiabilitiesListPage(updateExpenseCallback: (double ) {  },)),
                    );
                  },
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.attach_money),
                        SizedBox(width: 8),
                        Text('Liabilities'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 6),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddCategoryPage()), // Navigate to DeveloperPage
                    );
                  },
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.add_circle_outline),
                        SizedBox(width: 8),
                        Text('Add Category'),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 6),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DeveloperPage()), // Navigate to DeveloperPage
                    );
                  },
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Developer Info'),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
