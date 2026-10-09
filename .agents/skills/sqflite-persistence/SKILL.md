---
name: sqflite-persistence
description: >-
  Guide for implementing local SQLite persistence, indexing, ACID transactions, and companion
  image file storage using sqflite, path, and path_provider in Flutter. Activate this skill
  when creating database migrations, query services, or managing local receipt image files.
---

# SQLite Local Persistence & Storage Skill

This skill guides the implementation of local relational database storage and file management for **ReceiptMate**, ensuring data integrity (ACID), zero database bloat, fast queries (< 50ms), and clean image lifecycle handling.

---

## 1. Database Schema & Indexing

```sql
CREATE TABLE expenses (
  id TEXT PRIMARY KEY,
  merchant_name TEXT NOT NULL,
  total_amount REAL NOT NULL,
  transaction_date TEXT NOT NULL,
  category TEXT NOT NULL,
  note TEXT,
  receipt_image_path TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- Crucial indexes for date range reporting and category aggregation
CREATE INDEX idx_expenses_date ON expenses(transaction_date);
CREATE INDEX idx_expenses_category ON expenses(category);
```

---

## 2. Database Service Implementation (`DatabaseService`)

```dart
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense_item.dart';

class DatabaseService {
  static const String _dbName = 'receipt_mate.db';
  static const int _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses (
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
        await db.execute('CREATE INDEX idx_expenses_date ON expenses(transaction_date)');
        await db.execute('CREATE INDEX idx_expenses_category ON expenses(category)');
      },
    );
  }

  Future<int> insertExpense(ExpenseItem item) async {
    final db = await database;
    return await db.insert(
      'expenses',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExpenseItem>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'transaction_date DESC',
    );
    return List.generate(maps.length, (i) => ExpenseItem.fromMap(maps[i]));
  }

  /// Delete expense and automatically clean up associated local image file
  Future<void> deleteExpense(String id) async {
    final db = await database;
    final maps = await db.query(
      'expenses',
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
            // Ignore if file cannot be deleted
          }
        }
      }
    }

    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
```

---

## 3. Storage & Image File Rules

1. **NEVER Store Images as BLOB in SQLite:**
   - BLOBs cause database degradation and memory spikes during query scans.
   - Store ONLY the local file path string (`receipt_image_path`).
2. **Dedicated App Documents Directory:**
   - Save permanent images inside `getApplicationDocumentsDirectory() / 'receipts'`.
3. **Orphan File Prevention:**
   - When deleting an expense item from SQLite, always delete the corresponding image file from local storage.
4. **VND Normalization Rule:**
   - Amounts in SQLite must always be stored in real VND value (e.g., `150000.0`, NEVER `150.0`).
