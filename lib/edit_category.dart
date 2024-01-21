import 'package:flutter/material.dart';
import 'database_helper.dart';

class EditCategoryPage extends StatefulWidget {
  final Map<String, dynamic> category;
  final Function() onCategoryEdited;

  EditCategoryPage({
    required this.category,
    required this.onCategoryEdited,
  });

  @override
  _EditCategoryPageState createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final TextEditingController _categoryController = TextEditingController();
  final DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _categoryController.text = widget.category['category'];
  }

  void _editCategory() async {
    final updatedCategory = _categoryController.text;
    final categoryId = widget.category['id'];
    if (updatedCategory.isNotEmpty) {
      await databaseHelper.updateCategory(categoryId, updatedCategory);
      widget.onCategoryEdited();
      Navigator.pop(context); // Return to the previous page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Category'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category Name',
              ),
            ),
            ElevatedButton(
              onPressed: _editCategory,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
