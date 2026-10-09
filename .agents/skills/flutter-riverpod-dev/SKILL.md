---
name: flutter-riverpod-dev
description: >-
  Expert guide for developing Flutter 3.24+ mobile applications using Clean Layered Architecture,
  Riverpod 2 (Notifier / NotifierProvider), Sound Null Safety, Material 3 design system,
  and strict lifecycle resource management. Activate this skill when creating models, services,
  screens, widgets, or managing state in the ReceiptMate Flutter project.
---

# Flutter & Riverpod 2 Clean Architecture Skill

This skill guides the development and maintenance of the Flutter codebase for **ReceiptMate**, enforcing Clean Layered Architecture, Riverpod 2 reactive state management, Sound Null Safety, and Material 3 design standards.

---

## 1. Clean Layered Architecture Structure

Every feature or component must reside in its strictly designated layer under `lib/`:

```
lib/
├── core/                  # Constants, AppTheme (Material 3), formatters (currency, date)
│                          # NEVER import screens, widgets, or state from core/
├── models/                # Immutable data entities (ExpenseItem, ParsedReceipt, CategoryExpense)
│                          # Must have fromMap(), toMap(), copyWith(), and @immutable
├── services/              # Pure logic, I/O, SQLite, OCR, Storage
│                          # NEVER accept or depend on BuildContext
├── state/                 # Riverpod 2 Notifiers, AsyncNotifiers, Providers
│                          # Bridge between UI and Services
├── widgets/               # Reusable presentation components, CustomPainters
└── screens/               # Complete full-screen Views & Navigation shells
```

### Dependency Rules
- **UI (`screens`, `widgets`)** $\rightarrow$ interacts with data **ONLY** through Riverpod Providers (`ref.watch`, `ref.read`).
- **Services (`DatabaseService`, `OcrService`, `ReceiptParser`, `StorageService`)** must be pure Dart/Flutter services without `BuildContext`.
- **Core** must have zero dependencies on upper layers.

---

## 2. Riverpod 2 Implementation Patterns

### 2.1 State Notifier Pattern (Riverpod 2.5+)
Use `Notifier` and `NotifierProvider` for state management:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_item.dart';
import '../services/database_service.dart';

final expenseListProvider = NotifierProvider<ExpenseListNotifier, List<ExpenseItem>>(() {
  return ExpenseListNotifier();
});

class ExpenseListNotifier extends Notifier<List<ExpenseItem>> {
  late final DatabaseService _dbService;

  @override
  List<ExpenseItem> build() {
    _dbService = ref.read(databaseServiceProvider);
    _loadExpenses();
    return [];
  }

  Future<void> _loadExpenses() async {
    final list = await _dbService.getAllExpenses();
    state = list;
  }

  Future<void> addExpense(ExpenseItem item) async {
    await _dbService.insertExpense(item);
    state = [item, ...state];
  }

  Future<void> deleteExpense(String id) async {
    await _dbService.deleteExpense(id);
    state = state.where((item) => item.id != id).toList();
  }
}
```

### 2.2 Computed & Filtering Providers
Use functional providers for derived statistics:
```dart
final monthlyTotalProvider = Provider<double>((ref) {
  final expenses = ref.watch(expenseListProvider);
  final now = DateTime.now();
  return expenses
      .where((e) => e.transactionDate.month == now.month && e.transactionDate.year == now.year)
      .fold<double>(0.0, (sum, item) => sum + item.totalAmount);
});
```

---

## 3. Performance & Memory Leak Prevention Rules

1. **Const Constructors Everywhere:**
   - Always declare `const` for static widgets, paddings, decorations, and text styles.
2. **Strict Resource Disposal:**
   - In every `StatefulWidget`, all controllers and listeners MUST be disposed in `dispose()`:
   ```dart
   @override
   void dispose() {
     _amountController.dispose();
     _merchantController.dispose();
     _noteController.dispose();
     _focusNode.dispose();
     super.dispose();
   }
   ```
3. **No Heavy Work in `build()`:**
   - Never run Regex, File I/O, SQLite queries, or sorting algorithms inside `Widget.build()`. Compute them in Notifiers or Providers.
4. **Virtualized List Rendering:**
   - Always use `ListView.builder` with `key: ValueKey(item.id)`. Never use `SingleChildScrollView(child: Column(...))` for dynamic lists.

---

## 4. Material 3 Theming Guidelines

- **Seed Color:** VKU Navy (`Color(0xFF2C4570)`).
- **Surface Elevation:** Use `elevation: 0` with `Theme.of(context).colorScheme.surfaceContainer` for Material 3 card surfaces.
- **Responsiveness:** Always wrap forms in `SafeArea` and `SingleChildScrollView` with:
  ```dart
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  ```
  to eliminate `RenderFlex overflowed by N pixels`.
