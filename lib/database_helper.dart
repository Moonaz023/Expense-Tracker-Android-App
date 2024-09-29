import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ExpenseTracker.db');

    final database = await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            amount REAL,
            category TEXT,
            date TEXT,
            mode TEXT,
            note TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE liabilities(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            obligations TEXT,
            repaymentDate TEXT,
            interestPercentage REAL
          )
        ''');

        // Add the missing budgets table
        await db.execute('''
          CREATE TABLE budgets(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            budgetAmount REAL,
            month TEXT
          )
        ''');

        // Insert default categories
        await _insertDefaultCategories(db);
      },
      version: 1,
    );

    return database;
  }

  Future<void> _insertDefaultCategories(Database db) async {
    List<String> defaultCategories = [
      'Business',
      'Salary',
      'Food',
      'Transport',
      'Shopping',
      'Home',
      'Liability Payment'
    ];

    for (String category in defaultCategories) {
      await db.insert('categories', {'category': category});
    }
  }

  Future<int> insertTransaction(Map<String, dynamic> transactionData) async {
    final db = await database;
    String formattedDate =
    DateFormat('yyyy-MM-dd').format(transactionData['date']);
    transactionData['date'] = formattedDate;
    return await db.insert('transactions', transactionData);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return await db.query('transactions');
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTransaction(int id, Map<String, dynamic> updatedData) async {
    final db = await database;
    await db.update(
      'transactions',
      updatedData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertCategory(String category) async {
    final db = await database;
    final categoryData = {'category': category};
    return await db.insert('categories', categoryData);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateCategory(int id, String newCategory) async {
    final db = await database;
    final updatedData = {'category': newCategory};
    await db.update(
      'categories',
      updatedData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getCategoriesAndAmounts() async {
    final db = await database;
    List<Map<String, dynamic>> categoryData = await db.query('categories');

    List<Map<String, dynamic>> result = [];
    for (var category in categoryData) {
      String categoryName = category['category'];
      double totalAmount = 0;

      List<Map<String, dynamic>> categoryTransactions = await db.query(
        'transactions',
        where: 'category = ?',
        whereArgs: [categoryName],
      );

      for (var transaction in categoryTransactions) {
        totalAmount += transaction['amount'];
      }

      result.add({
        'category': categoryName,
        'amount': totalAmount,
      });
    }

    return result;
  }

  Future<int> insertLiability(double amount, String obligations,
      repaymentDate, double interestPercentage) async {
    final db = await database;
    return await db.insert(
      'liabilities',
      {
        'amount': amount,
        'obligations': obligations,
        'repaymentDate': repaymentDate,
        'interestPercentage': interestPercentage,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getLiabilities() async {
    final db = await database;
    return await db.query('liabilities');
  }

  Future<double> deleteLiability(int id) async {
    final db = await database;
    var liability =
    await db.query('liabilities', where: 'id = ?', whereArgs: [id]);

    if (liability.isNotEmpty) {
      double amount = liability[0]['amount'] as double;
      double interestPercentage = liability[0]['interestPercentage'] as double;
      double totalAmount = amount + (amount * (interestPercentage / 100));
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      // Add the liability as an expense transaction
      await db.insert('transactions', {
        'type': 'Expense',
        'amount': totalAmount,
        'category': 'Liability Payment',
        'date': formattedDate,
        'mode': 'Cash',
        'note': 'Liability Payment',
      });

      // Delete the liability from the liabilities table
      await db.delete('liabilities', where: 'id = ?', whereArgs: [id]);

      return totalAmount;
    }

    return 0;
  }

  // Budget table methods

  // Future<int> insertBudget(
  //     String category, double budgetAmount, String month) async {
  //   final db = await database;
  //   final budgetData = {
  //     'category': category,
  //     'budgetAmount': budgetAmount,
  //     'month': month
  //   };
  //   return await db.insert('budgets', budgetData);
  // }

  // new insert budget
  Future<int> insertBudget(String category, double budgetAmount, String month) async {
    final db = await database;

    // Check if a budget for the same category and month already exists
    List<Map<String, dynamic>> existingBudgets = await db.query(
      'budgets',
      where: 'category = ? AND month = ?',
      whereArgs: [category, month],
    );

    if (existingBudgets.isNotEmpty) {
      // Update the existing budget
      double existingAmount = existingBudgets[0]['budgetAmount'];
      double newAmount = existingAmount + budgetAmount; // Add the new budget to the existing amount

      await db.update(
        'budgets',
        {'budgetAmount': newAmount},
        where: 'id = ?',
        whereArgs: [existingBudgets[0]['id']],
      );

      return existingBudgets[0]['id']; // Return the ID of the updated budget
    } else {
      // Insert new budget
      final budgetData = {
        'category': category,
        'budgetAmount': budgetAmount,
        'month': month
      };
      return await db.insert('budgets', budgetData);
    }
  }


  Future<List<Map<String, dynamic>>> getBudgets() async {
    final db = await database;
    return await db.query('budgets');
  }

  Future<void> deleteBudget(int id) async {
    final db = await database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateBudget(int id, String category, double budgetAmount,
      String month) async {
    final db = await database;
    final updatedData = {
      'category': category,
      'budgetAmount': budgetAmount,
      'month': month
    };
    await db.update(
      'budgets',
      updatedData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
