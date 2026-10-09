import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/expense_item.dart';
import '../../models/parsed_receipt.dart';
import '../../state/expense_providers.dart';
import '../../widgets/common/custom_text_field.dart';

/// Screen for reviewing, verifying, and confirming OCR or manual expense entries.
/// Strictly enforces the "Never Trust OCR Blindly" principle with full user agency.
class ReviewScreen extends ConsumerStatefulWidget {
  final ParsedReceipt? parsedReceipt;
  final String? initialImagePath;
  final ExpenseItem? existingExpense;

  const ReviewScreen({
    super.key,
    this.parsedReceipt,
    this.initialImagePath,
    this.existingExpense,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _merchantController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late DateTime _selectedDate;
  late String _selectedCategory;
  String? _imagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final existing = widget.existingExpense;
    final parsed = widget.parsedReceipt;

    if (existing != null) {
      _merchantController = TextEditingController(text: existing.merchantName);
      _amountController = TextEditingController(text: existing.totalAmount.round().toString());
      _noteController = TextEditingController(text: existing.note ?? '');
      _selectedDate = existing.transactionDate;
      _selectedCategory = existing.category;
      _imagePath = existing.receiptImagePath;
    } else {
      _merchantController = TextEditingController(text: parsed?.merchantName ?? '');
      final amount = parsed?.totalAmount;
      _amountController = TextEditingController(
        text: amount != null && amount > 0 ? amount.round().toString() : '',
      );
      _noteController = TextEditingController();
      _selectedDate = parsed?.transactionDate ?? DateTime.now();
      _selectedCategory = parsed?.suggestedCategory ?? AppConstants.catFood;
      _imagePath = widget.initialImagePath ?? parsed?.imagePath;
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final storageService = ref.read(storageServiceProvider);
      String? permanentImagePath = _imagePath;

      // If this is a new scan from temporary path, persist to app documents directory
      if (_imagePath != null && widget.existingExpense == null) {
        try {
          permanentImagePath = await storageService.saveReceiptImage(_imagePath!);
        } catch (_) {
          permanentImagePath = _imagePath;
        }
      }

      final amount = CurrencyFormatter.parseUserInput(_amountController.text) ?? 0.0;
      final now = DateTime.now();

      if (widget.existingExpense != null) {
        final updatedItem = widget.existingExpense!.copyWith(
          merchantName: _merchantController.text.trim(),
          totalAmount: amount,
          transactionDate: _selectedDate,
          category: _selectedCategory,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          receiptImagePath: permanentImagePath,
          updatedAt: now,
        );
        await ref.read(expenseListProvider.notifier).updateExpense(updatedItem);
      } else {
        final newItem = ExpenseItem(
          id: const Uuid().v4(),
          merchantName: _merchantController.text.trim(),
          totalAmount: amount,
          transactionDate: _selectedDate,
          category: _selectedCategory,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          receiptImagePath: permanentImagePath,
          createdAt: now,
          updatedAt: now,
        );
        await ref.read(expenseListProvider.notifier).addExpense(newItem);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingExpense != null
                  ? 'Đã cập nhật chi tiêu'
                  : 'Đã lưu chi tiêu thành công',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingExpense != null;

    // Helper preview for current typed amount in VND
    final currentTypedAmount = CurrencyFormatter.parseUserInput(_amountController.text);

    final bool hasChanges = _merchantController.text.isNotEmpty || _amountController.text.isNotEmpty;
    final isMerchantSuggested = widget.parsedReceipt?.merchantName != null &&
        widget.parsedReceipt!.merchantName!.isNotEmpty;
    final isAmountSuggested = widget.parsedReceipt?.totalAmount != null &&
        widget.parsedReceipt!.totalAmount! > 0;

    return PopScope(
      canPop: !hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hủy bỏ chi tiêu này?'),
            content: const Text('Thông tin bạn vừa nhập và ảnh hóa đơn sẽ không được lưu lại.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Tiếp tục sửa'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Hủy bỏ'),
              ),
            ],
          ),
        );
        if (shouldLeave == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Chỉnh sửa chi tiêu' : 'Xác nhận thông tin'),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Lưu',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // OCR Verification Notice Banner
                  if (widget.parsedReceipt != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Thông tin được gợi ý tự động bằng OCR. Vui lòng kiểm tra kỹ trước khi lưu.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Scanned Receipt Image Preview with Pinch-to-Zoom
                  if (_imagePath != null && _imagePath!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            InteractiveViewer(
                              minScale: 1.0,
                              maxScale: 3.0,
                              child: Image.file(
                                File(_imagePath!),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image_rounded, size: 36),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton.filled(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => setState(() => _imagePath = null),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.pinch_rounded, color: Colors.white, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'Chụm để phóng to',
                                      style: TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Merchant Name Field with Sparkle auto-suggest badge
                  CustomTextField(
                    label: 'Tên cửa hàng / Dịch vụ *',
                    hint: 'VD: Highlands Coffee, WinMart...',
                    controller: _merchantController,
                    prefixIcon: const Icon(Icons.storefront_rounded, size: 20),
                    suffixIcon: isMerchantSuggested
                        ? const Tooltip(
                            message: 'Tự động gợi ý từ hóa đơn',
                            child: Icon(Icons.auto_awesome_rounded, color: AppColors.success, size: 18),
                          )
                        : null,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên nơi mua sắm / cửa hàng';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Amount Field with VND Helper and Sparkle auto-suggest badge
                  CustomTextField(
                    label: 'Số tiền thanh toán (VND) *',
                    hint: 'VD: 45000 hoặc 45k',
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.attach_money_rounded, size: 20),
                    suffixIcon: isAmountSuggested
                        ? const Tooltip(
                            message: 'Tự động nhận diện tổng tiền',
                            child: Icon(Icons.auto_awesome_rounded, color: AppColors.success, size: 18),
                          )
                        : null,
                    onChanged: (val) => setState(() {}),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập số tiền chi tiêu';
                      }
                      final parsed = CurrencyFormatter.parseUserInput(value);
                      if (parsed == null || parsed <= 0) {
                        return 'Số tiền phải là số hợp lệ lớn hơn 0';
                      }
                      return null;
                    },
                  ),

                if (currentTypedAmount != null && currentTypedAmount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      'Bằng chữ / Chuẩn hóa: ${CurrencyFormatter.format(currentTypedAmount)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Transaction Date Picker
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Ngày giao dịch:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          DateFormatter.format(_selectedDate),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Category Selection Chips
                Text(
                  'Danh mục chi tiêu',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.categories.map((cat) {
                    final isSelected = _selectedCategory == cat.key;
                    return FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat.icon,
                            size: 16,
                            color: isSelected ? Colors.white : cat.color,
                          ),
                          const SizedBox(width: 6),
                          Text(cat.displayName),
                        ],
                      ),
                      selectedColor: cat.color,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = cat.key);
                        }
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Note Field (Optional)
                CustomTextField(
                  label: 'Ghi chú (Tùy chọn)',
                  hint: 'VD: Ăn trưa với bạn bè, mua quà...',
                  controller: _noteController,
                  maxLines: 2,
                  prefixIcon: const Icon(Icons.edit_note_rounded, size: 20),
                ),

                const SizedBox(height: 32),

                // Primary Save Button
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _handleSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(_isSaving ? 'Đang lưu...' : 'Lưu chi tiêu'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
