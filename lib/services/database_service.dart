import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../core/constants/app_constants.dart';
import '../models/expense_item.dart';

/// DatabaseService handles local SQLite persistence for ReceiptMate.
/// Implements ACID transactions, indexing for high-speed queries,
/// and automated companion image cleanup on deletion.
class DatabaseService {
  Database? _db;

  /// Get initialized Database instance (lazy initialized)
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${AppConstants.expensesTable} (
            id TEXT PRIMARY KEY,
            merchant_name TEXT NOT NULL,
            total_amount REAL NOT NULL,
            transaction_date TEXT NOT NULL,
            category TEXT NOT NULL,
            note TEXT,
            receipt_image_path TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        // High-performance indexing for date queries and category aggregation
        await db.execute(
          'CREATE INDEX idx_expenses_date ON ${AppConstants.expensesTable}(transaction_date)',
        );
        await db.execute(
          'CREATE INDEX idx_expenses_category ON ${AppConstants.expensesTable}(category)',
        );
      },
    );
  }

  /// Insert a new expense record
  Future<int> insertExpense(ExpenseItem item) async {
    final db = await database;
    return await db.insert(
      AppConstants.expensesTable,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing expense record
  Future<int> updateExpense(ExpenseItem item) async {
    final db = await database;
    return await db.update(
      AppConstants.expensesTable,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Retrieve all expenses ordered by date descending
  Future<List<ExpenseItem>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.expensesTable,
      orderBy: 'transaction_date DESC',
    );
    return List.generate(maps.length, (i) => ExpenseItem.fromMap(maps[i]));
  }

  /// Retrieve expenses within a date range
  Future<List<ExpenseItem>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.expensesTable,
      where: 'transaction_date >= ? AND transaction_date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'transaction_date DESC',
    );
    return List.generate(maps.length, (i) => ExpenseItem.fromMap(maps[i]));
  }

  /// Retrieve single expense by ID
  Future<ExpenseItem?> getExpenseById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.expensesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ExpenseItem.fromMap(maps.first);
  }

  /// Delete expense by ID and automatically clean up associated local image file
  Future<void> deleteExpense(String id) async {
    final db = await database;

    // Check if there is an associated image file
    final maps = await db.query(
      AppConstants.expensesTable,
      columns: ['receipt_image_path'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final imagePath = maps.first['receipt_image_path'] as String?;
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {
            // Ignore if image file cannot be deleted
          }
        }
      }
    }

    await db.delete(
      AppConstants.expensesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Close database connection
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
