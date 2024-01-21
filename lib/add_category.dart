import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'edit_category.dart';

class AddCategoryPage extends StatefulWidget {
  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _categoryController = TextEditingController();
  final DatabaseHelper databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() async {
    final categories = await databaseHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  void _addCategory() async {
    final category = _categoryController.text;
    if (category.isNotEmpty) {
      await databaseHelper.insertCategory(category);
      _categoryController.clear();
      _fetchCategories();
    }
  }

  void _deleteCategory(int id) async {
    await databaseHelper.deleteCategory(id);
    _fetchCategories();
  }

  Future<void> _confirmDeleteCategory(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this category?'),
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
                _deleteCategory(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void editCategory(Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryPage(
          category: category,
          onCategoryEdited: () {
            _fetchCategories();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Category'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              labelText: 'Category Name',
            ),
          ),
          ElevatedButton(
            onPressed: _addCategory,
            child: Text('Add Category'),
          ),
          SizedBox(height: 20),
          Text('Existing Categories:'),
          for (var category in _categories)
            ListTile(
              title: Text(category['category']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      editCategory(category);
                      // Implement edit category functionality
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _confirmDeleteCategory(category['id']);
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
