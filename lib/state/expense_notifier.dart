import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../models/expense_item.dart';
import '../services/database_service.dart';
import 'expense_providers.dart';

/// Notifier managing the in-memory list of expenses synchronized with SQLite
class ExpenseListNotifier extends Notifier<List<ExpenseItem>> {
  late final DatabaseService _dbService;
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  @override
  List<ExpenseItem> build() {
    _dbService = ref.read(databaseServiceProvider);
    _loadInitialData();
    return const [];
  }

  Future<void> _loadInitialData() async {
    _isLoading = true;
    try {
      final list = await _dbService.getAllExpenses();
      state = list;
    } catch (_) {
      state = [];
    } finally {
      _isLoading = false;
    }
  }

  /// Manually refresh expenses from SQLite
  Future<void> refreshExpenses() async {
    final list = await _dbService.getAllExpenses();
    state = list;
  }

  /// Add a new expense record to SQLite and prepend to state
  Future<void> addExpense(ExpenseItem item) async {
    await _dbService.insertExpense(item);
    state = [item, ...state];
  }

  /// Update an existing expense in SQLite and update state
  Future<void> updateExpense(ExpenseItem item) async {
    await _dbService.updateExpense(item);
    state = [
      for (final existing in state)
        if (existing.id == item.id) item else existing,
    ];
  }

  /// Delete an expense by ID and remove from state
  Future<void> deleteExpense(String id) async {
    await _dbService.deleteExpense(id);
    state = state.where((item) => item.id != id).toList();
  }

  /// Loads realistic sample data for instant demonstration and testing
  Future<void> loadSampleData() async {
    final now = DateTime.now();
    const uuid = Uuid();
    final sampleExpenses = [
      ExpenseItem(
        id: uuid.v4(),
        merchantName: 'Highlands Coffee',
        totalAmount: 65000.0,
        transactionDate: now.subtract(const Duration(hours: 3)),
        category: AppConstants.catFood,
        note: 'Cà phê phin sữa đá & bánh mì',
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      ExpenseItem(
        id: uuid.v4(),
        merchantName: 'WinMart+',
        totalAmount: 185000.0,
        transactionDate: now.subtract(const Duration(days: 1, hours: 2)),
        category: AppConstants.catShopping,
        note: 'Sữa tươi TH True Milk, bánh mì, trái cây',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      ExpenseItem(
        id: uuid.v4(),
        merchantName: 'Grab Bike',
        totalAmount: 38000.0,
        transactionDate: now.subtract(const Duration(days: 2)),
        category: AppConstants.catTransport,
        note: 'Chuyến xe đi trường ĐH VKU',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      ExpenseItem(
        id: uuid.v4(),
        merchantName: 'Tiền điện EVN',
        totalAmount: 420000.0,
        transactionDate: now.subtract(const Duration(days: 3)),
        category: AppConstants.catUtilities,
        note: 'Thanh toán tiền điện sinh hoạt tháng',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      ExpenseItem(
        id: uuid.v4(),
        merchantName: 'Circle K',
        totalAmount: 45000.0,
        transactionDate: now.subtract(const Duration(days: 4)),
        category: AppConstants.catShopping,
        note: 'Nước ngọt & đồ ăn vặt',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      ExpenseItem(
        id: uuid.v4(),
        merchantName: 'Nhà sách Fahasa',
        totalAmount: 125000.0,
        transactionDate: now.subtract(const Duration(days: 5)),
        category: AppConstants.catOther,
        note: 'Sổ tay ghi chú & bút bi',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];

    for (final item in sampleExpenses) {
      await addExpense(item);
    }
  }
}
