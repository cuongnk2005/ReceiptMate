import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Metadata definition for expense categories
class ExpenseCategoryInfo {
  final String key;
  final String displayName;
  final IconData icon;
  final Color color;

  const ExpenseCategoryInfo({
    required this.key,
    required this.displayName,
    required this.icon,
    required this.color,
  });
}

/// Global constants and category definitions for ReceiptMate
class AppConstants {
  AppConstants._();

  static const String appName = 'ReceiptMate';
  static const String currencySymbol = 'đ';
  static const String currencyCode = 'VND';

  // Database Constants
  static const String dbName = 'receipt_mate.db';
  static const int dbVersion = 1;
  static const String expensesTable = 'expenses';
  static const String receiptsFolderName = 'receipts';

  // Categories Keys
  static const String catFood = 'food';
  static const String catShopping = 'shopping';
  static const String catTransport = 'transport';
  static const String catUtilities = 'utilities';
  static const String catOther = 'other';

  // Master Categories list
  static const List<ExpenseCategoryInfo> categories = [
    ExpenseCategoryInfo(
      key: catFood,
      displayName: 'Ăn uống',
      icon: Icons.restaurant_rounded,
      color: AppColors.categoryFood,
    ),
    ExpenseCategoryInfo(
      key: catShopping,
      displayName: 'Mua sắm',
      icon: Icons.shopping_bag_rounded,
      color: AppColors.categoryShopping,
    ),
    ExpenseCategoryInfo(
      key: catTransport,
      displayName: 'Di chuyển',
      icon: Icons.directions_car_rounded,
      color: AppColors.categoryTransport,
    ),
    ExpenseCategoryInfo(
      key: catUtilities,
      displayName: 'Hóa đơn & Tiện ích',
      icon: Icons.receipt_long_rounded,
      color: AppColors.categoryUtilities,
    ),
    ExpenseCategoryInfo(
      key: catOther,
      displayName: 'Chi tiêu khác',
      icon: Icons.more_horiz_rounded,
      color: AppColors.categoryOther,
    ),
  ];

  /// Find CategoryInfo by key with fallback to Other
  static ExpenseCategoryInfo getCategoryInfo(String key) {
    return categories.firstWhere(
      (c) => c.key.toLowerCase() == key.toLowerCase(),
      orElse: () => categories.last,
    );
  }

  /// Get localized display name for category
  static String getCategoryDisplayName(String key) {
    return getCategoryInfo(key).displayName;
  }

  /// Get icon for category
  static IconData getCategoryIcon(String key) {
    return getCategoryInfo(key).icon;
  }
}
