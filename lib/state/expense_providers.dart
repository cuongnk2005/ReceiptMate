import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/text_normalizer.dart';
import '../models/category_expense.dart';
import '../models/expense_item.dart';
import '../services/database_service.dart';
import '../services/ocr_service.dart';
import '../services/storage_service.dart';
import 'expense_notifier.dart';

/// Database service provider (Singleton-like lifetime managed by Riverpod)
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final service = DatabaseService();
  ref.onDispose(() => service.close());
  return service;
});

/// Storage service provider for handling local image files
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// OCR service provider for on-device ML Kit recognition
final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Global reactive expense list provider
final expenseListProvider = NotifierProvider<ExpenseListNotifier, List<ExpenseItem>>(
  ExpenseListNotifier.new,
);

/// Total spending for the current calendar month
final monthlyTotalProvider = Provider<double>((ref) {
  final expenses = ref.watch(expenseListProvider);
  final now = DateTime.now();

  return expenses
      .where((e) => e.transactionDate.month == now.month && e.transactionDate.year == now.year)
      .fold<double>(0.0, (sum, item) => sum + item.totalAmount);
});

/// Top 5 most recent transactions
final recentExpensesProvider = Provider<List<ExpenseItem>>((ref) {
  final expenses = ref.watch(expenseListProvider);
  return expenses.take(5).toList();
});

/// Aggregated spending breakdown by category for the current month (or all-time if month empty)
final categoryBreakdownProvider = Provider<List<CategoryExpense>>((ref) {
  final expenses = ref.watch(expenseListProvider);
  final now = DateTime.now();

  // Filter current month transactions first; fallback to all if current month has none
  var currentMonthExpenses = expenses
      .where((e) => e.transactionDate.month == now.month && e.transactionDate.year == now.year)
      .toList();

  final effectiveList = currentMonthExpenses.isNotEmpty ? currentMonthExpenses : expenses;
  final totalSpent = effectiveList.fold<double>(0.0, (sum, e) => sum + e.totalAmount);

  if (totalSpent == 0) return const [];

  // Group by category key
  final Map<String, double> categorySums = {};
  final Map<String, int> categoryCounts = {};

  for (final item in effectiveList) {
    categorySums[item.category] = (categorySums[item.category] ?? 0.0) + item.totalAmount;
    categoryCounts[item.category] = (categoryCounts[item.category] ?? 0) + 1;
  }

  final List<CategoryExpense> breakdown = [];
  for (final catInfo in AppConstants.categories) {
    final amount = categorySums[catInfo.key] ?? 0.0;
    if (amount > 0) {
      breakdown.add(
        CategoryExpense(
          categoryKey: catInfo.key,
          categoryName: catInfo.displayName,
          amount: amount,
          percentage: amount / totalSpent,
          color: catInfo.color,
          icon: catInfo.icon,
          transactionCount: categoryCounts[catInfo.key] ?? 0,
        ),
      );
    }
  }

  // Sort descending by amount
  breakdown.sort((a, b) => b.amount.compareTo(a.amount));
  return breakdown;
});

/// Spending array for the current week: [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
final weeklySpendingProvider = Provider<List<double>>((ref) {
  final expenses = ref.watch(expenseListProvider);
  final now = DateTime.now();
  final currentWeekday = now.weekday; // 1 (Mon) .. 7 (Sun)
  final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: currentWeekday - 1));

  final weeklyAmounts = List<double>.filled(7, 0.0);

  for (int i = 0; i < 7; i++) {
    final day = monday.add(Duration(days: i));
    final nextDay = day.add(const Duration(days: 1));

    final dayTotal = expenses
        .where((e) => e.transactionDate.isAfter(day.subtract(const Duration(milliseconds: 1))) &&
                      e.transactionDate.isBefore(nextDay))
        .fold<double>(0.0, (sum, item) => sum + item.totalAmount);

    weeklyAmounts[i] = dayTotal;
  }

  return weeklyAmounts;
});

/// Active search query in Expense List screen
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Active category filter in Expense List screen (null means All)
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Filtered expenses based on search query and category filter
final filteredExpensesProvider = Provider<List<ExpenseItem>>((ref) {
  final expenses = ref.watch(expenseListProvider);
  final query = ref.watch(searchQueryProvider).trim();
  final selectedCat = ref.watch(selectedCategoryFilterProvider);

  return expenses.where((item) {
    // Category match
    if (selectedCat != null && item.category != selectedCat) {
      return false;
    }
    // Diacritic-insensitive and case-insensitive search match (merchant name or note)
    if (query.isNotEmpty) {
      final matchesMerchant = TextNormalizer.matches(item.merchantName, query);
      final matchesNote = item.note != null && TextNormalizer.matches(item.note!, query);
      if (!matchesMerchant && !matchesNote) {
        return false;
      }
    }
    return true;
  }).toList();
});
