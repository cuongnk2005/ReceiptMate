import 'package:flutter/material.dart';

/// Presentation model representing aggregated spending for a specific category.
/// Used directly by CategoryDonutPainter and dashboard statistics.
@immutable
class CategoryExpense {
  final String categoryKey;
  final String categoryName;
  final double amount;
  final double percentage; // 0.0 to 1.0
  final Color color;
  final IconData icon;
  final int transactionCount;

  const CategoryExpense({
    required this.categoryKey,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.icon,
    required this.transactionCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryExpense &&
          runtimeType == other.runtimeType &&
          categoryKey == other.categoryKey &&
          amount == other.amount &&
          percentage == other.percentage &&
          transactionCount == other.transactionCount;

  @override
  int get hashCode =>
      categoryKey.hashCode ^
      amount.hashCode ^
      percentage.hashCode ^
      transactionCount.hashCode;
}
