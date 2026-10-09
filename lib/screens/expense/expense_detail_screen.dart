import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/expense_item.dart';
import '../../state/expense_providers.dart';
import '../review/review_screen.dart';
import '../../widgets/common/full_screen_image_viewer.dart';

/// Screen presenting full details of a single ExpenseItem, including receipt photo
class ExpenseDetailScreen extends ConsumerWidget {
  final ExpenseItem expense;

  const ExpenseDetailScreen({
    super.key,
    required this.expense,
  });

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa khoản chi tiêu này? Ảnh hóa đơn liên kết (nếu có) cũng sẽ được xóa khỏi thiết bị.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(expenseListProvider.notifier).deleteExpense(expense.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa khoản chi tiêu'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryInfo = AppConstants.getCategoryInfo(expense.category);
    final categoryColor = AppColors.getCategoryColor(expense.category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết chi tiêu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Chỉnh sửa',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReviewScreen(existingExpense: expense),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.error,
            tooltip: 'Xóa',
            onPressed: () => _handleDelete(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with Amount and Merchant
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(categoryInfo.icon, color: categoryColor, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      expense.merchantName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(expense.totalAmount),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Transaction Info Rows
              _buildInfoRow(
                context,
                icon: Icons.calendar_today_rounded,
                label: 'Ngày giao dịch',
                value: DateFormatter.format(expense.transactionDate),
              ),
              const Divider(height: 24),

              _buildInfoRow(
                context,
                icon: Icons.category_rounded,
                label: 'Danh mục',
                value: categoryInfo.displayName,
                valueColor: categoryColor,
              ),
              const Divider(height: 24),

              if (expense.note != null && expense.note!.isNotEmpty) ...[
                _buildInfoRow(
                  context,
                  icon: Icons.notes_rounded,
                  label: 'Ghi chú',
                  value: expense.note!,
                ),
                const Divider(height: 24),
              ],

              _buildInfoRow(
                context,
                icon: Icons.access_time_rounded,
                label: 'Tạo lúc',
                value: DateFormatter.formatWithTime(expense.createdAt),
              ),

              const SizedBox(height: 28),

              // Scanned Receipt Image (if available)
              if (expense.receiptImagePath != null && expense.receiptImagePath!.isNotEmpty) ...[
                Text(
                  'Hóa đơn đính kèm',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FullScreenImageViewer(
                          imagePath: expense.receiptImagePath!,
                          title: 'Hóa đơn: ${expense.merchantName}',
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 380),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Image.file(
                            File(expense.receiptImagePath!),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Không thể tải ảnh hóa đơn',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Chạm để phóng to',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
