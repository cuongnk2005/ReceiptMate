import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../state/expense_providers.dart';
import '../../state/theme_provider.dart';
import '../../widgets/cards/expense_item_tile.dart';
import '../../widgets/cards/expense_summary_card.dart';
import '../../widgets/charts/animated_donut_chart.dart';
import '../../widgets/charts/weekly_bar_chart.dart';
import '../expense/expense_detail_screen.dart';
import '../review/review_screen.dart';
import '../scan/ocr_scan_screen.dart';

/// Central dashboard screen displaying spending summary, charts, and recent activity
class DashboardScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToList;

  const DashboardScreen({
    super.key,
    this.onNavigateToList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final monthlyTotal = ref.watch(monthlyTotalProvider);
    final weeklySpending = ref.watch(weeklySpendingProvider);
    final categoryBreakdown = ref.watch(categoryBreakdownProvider);
    final recentExpenses = ref.watch(recentExpensesProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text('ReceiptMate'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.dark_mode_rounded
                  : themeMode == ThemeMode.light
                      ? Icons.light_mode_rounded
                      : Icons.brightness_auto_rounded,
            ),
            tooltip: 'Chọn giao diện',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => SimpleDialog(
                  title: const Text('Chọn chủ đề giao diện'),
                  children: [
                    SimpleDialogOption(
                      onPressed: () {
                        ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                        Navigator.of(ctx).pop();
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.light_mode_rounded, color: Colors.amber),
                          const SizedBox(width: 12),
                          const Text('Giao diện Sáng'),
                          const Spacer(),
                          if (themeMode == ThemeMode.light)
                            const Icon(Icons.check_rounded, color: AppColors.primary),
                        ],
                      ),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                        Navigator.of(ctx).pop();
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.dark_mode_rounded, color: Color(0xFF8AB4F8)),
                          const SizedBox(width: 12),
                          const Text('Giao diện Tối'),
                          const Spacer(),
                          if (themeMode == ThemeMode.dark)
                            const Icon(Icons.check_rounded, color: AppColors.primary),
                        ],
                      ),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                        Navigator.of(ctx).pop();
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.brightness_auto_rounded, color: Colors.blueGrey),
                          const SizedBox(width: 12),
                          const Text('Theo hệ thống'),
                          const Spacer(),
                          if (themeMode == ThemeMode.system)
                            const Icon(Icons.check_rounded, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Monthly Summary Card
              ExpenseSummaryCard(
                monthlyTotal: monthlyTotal,
                onScanPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OcrScanScreen()),
                  );
                },
                onAddManualPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReviewScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Weekly Spending Bar Chart Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: WeeklyBarChart(weeklyAmounts: weeklySpending),
                ),
              ),

              const SizedBox(height: 16),

              // Category Donut Chart Card
              if (categoryBreakdown.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cơ cấu chi tiêu',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedDonutChart(
                          slices: categoryBreakdown,
                          totalAmount: monthlyTotal,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Giao dịch gần đây',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (onNavigateToList != null && recentExpenses.isNotEmpty)
                    TextButton(
                      onPressed: onNavigateToList,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Xem tất cả'),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Recent Transactions List
              if (recentExpenses.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_outlined,
                        size: 36,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Chưa có giao dịch nào',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hãy quét hóa đơn đầu tiên của bạn để bắt đầu theo dõi chi tiêu',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          ref.read(expenseListProvider.notifier).loadSampleData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã nạp 6 giao dịch mẫu để thử nghiệm tính năng'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.dataset_outlined, size: 18),
                        label: const Text('Nạp dữ liệu mẫu thử nghiệm'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(200, 40),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentExpenses.length,
                      separatorBuilder: (context, index) => const Divider(height: 8),
                      itemBuilder: (context, index) {
                        final expense = recentExpenses[index];
                        return ExpenseItemTile(
                          expense: expense,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ExpenseDetailScreen(expense: expense),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
