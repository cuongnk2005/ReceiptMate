import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/expense_item.dart';
import '../../state/expense_providers.dart';
import '../../widgets/cards/expense_item_tile.dart';
import '../../widgets/common/empty_state_view.dart';
import 'expense_detail_screen.dart';

/// Full history screen with real-time search, category filters, date grouping, and swipe-to-delete
class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Groups expenses by date string (yyyy-MM-dd)
  Map<String, List<ExpenseItem>> _groupByDate(List<ExpenseItem> list) {
    final Map<String, List<ExpenseItem>> grouped = {};
    for (final item in list) {
      final key = DateFormatter.format(item.transactionDate);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredExpenses = ref.watch(filteredExpensesProvider);
    final selectedCat = ref.watch(selectedCategoryFilterProvider);
    final groupedData = _groupByDate(filteredExpenses);
    final dateKeys = groupedData.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử chi tiêu'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm cửa hàng, ghi chú...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Horizontal Category Filter Chips
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // "Tất cả" chip
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: selectedCat == null,
                      label: const Text('Tất cả'),
                      onSelected: (_) =>
                          ref.read(selectedCategoryFilterProvider.notifier).state = null,
                    ),
                  ),
                  // Individual Category chips
                  ...AppConstants.categories.map((cat) {
                    final isSelected = selectedCat == cat.key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat.displayName),
                        selectedColor: cat.color.withValues(alpha: 0.2),
                        checkmarkColor: cat.color,
                        labelStyle: TextStyle(
                          color: isSelected ? cat.color : theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (selected) {
                          ref.read(selectedCategoryFilterProvider.notifier).state =
                              selected ? cat.key : null;
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Virtualized Grouped List View with Pull-To-Refresh
            Expanded(
              child: filteredExpenses.isEmpty
                  ? EmptyStateView(
                      icon: Icons.receipt_long_outlined,
                      title: 'Không tìm thấy chi tiêu',
                      description: _searchController.text.isNotEmpty || selectedCat != null
                          ? 'Thử điều chỉnh từ khóa tìm kiếm hoặc bỏ chọn bộ lọc'
                          : 'Bắt đầu quét hóa đơn hoặc nhập chi tiêu đầu tiên của bạn',
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(expenseListProvider.notifier).refreshExpenses(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: dateKeys.length,
                        itemBuilder: (context, dateIndex) {
                          final dateKey = dateKeys[dateIndex];
                          final dayExpenses = groupedData[dateKey]!;
                          final dayTotal = dayExpenses.fold<double>(0.0, (s, e) => s + e.totalAmount);
                          final firstDate = dayExpenses.first.transactionDate;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date Group Header
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormatter.formatRelative(firstDate),
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(dayTotal),
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Items in this date group
                              Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: dayExpenses.length,
                                    separatorBuilder: (context, idx) => const Divider(height: 8),
                                    itemBuilder: (context, idx) {
                                      final expense = dayExpenses[idx];

                                      return Dismissible(
                                        key: ValueKey(expense.id),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.only(right: 20),
                                          decoration: BoxDecoration(
                                            color: AppColors.error,
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Xóa',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.delete_rounded, color: Colors.white),
                                            ],
                                          ),
                                        ),
                                        onDismissed: (direction) async {
                                          final deletedItem = expense;
                                          await ref
                                              .read(expenseListProvider.notifier)
                                              .deleteExpense(expense.id);

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Đã xóa "${deletedItem.merchantName}"'),
                                                behavior: SnackBarBehavior.floating,
                                                action: SnackBarAction(
                                                  label: 'Hoàn tác',
                                                  textColor: Colors.amber,
                                                  onPressed: () {
                                                    ref
                                                        .read(expenseListProvider.notifier)
                                                        .addExpense(deletedItem);
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: ExpenseItemTile(
                                          expense: expense,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => ExpenseDetailScreen(expense: expense),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
