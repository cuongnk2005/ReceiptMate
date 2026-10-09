import 'package:flutter/foundation.dart';

/// Immutable entity representing an expense transaction in ReceiptMate.
/// Strictly follows SQLite schema requirements and Clean Architecture.
@immutable
class ExpenseItem {
  final String id;
  final String merchantName;
  final double totalAmount;
  final DateTime transactionDate;
  final String category;
  final String? note;
  final String? receiptImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseItem({
    required this.id,
    required this.merchantName,
    required this.totalAmount,
    required this.transactionDate,
    required this.category,
    this.note,
    this.receiptImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to SQLite Map matching `expenses` table schema
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchant_name': merchantName,
      'total_amount': totalAmount,
      'transaction_date': transactionDate.toIso8601String(),
      'category': category,
      'note': note,
      'receipt_image_path': receiptImagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create ExpenseItem from SQLite database row
  factory ExpenseItem.fromMap(Map<String, dynamic> map) {
    return ExpenseItem(
      id: map['id'] as String,
      merchantName: map['merchant_name'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      category: map['category'] as String,
      note: map['note'] as String?,
      receiptImagePath: map['receipt_image_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Create an immutable copy with overridden fields
  ExpenseItem copyWith({
    String? id,
    String? merchantName,
    double? totalAmount,
    DateTime? transactionDate,
    String? category,
    String? note,
    String? receiptImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      merchantName: merchantName ?? this.merchantName,
      totalAmount: totalAmount ?? this.totalAmount,
      transactionDate: transactionDate ?? this.transactionDate,
      category: category ?? this.category,
      note: note ?? this.note,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          merchantName == other.merchantName &&
          totalAmount == other.totalAmount &&
          transactionDate == other.transactionDate &&
          category == other.category &&
          note == other.note &&
          receiptImagePath == other.receiptImagePath &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      merchantName.hashCode ^
      totalAmount.hashCode ^
      transactionDate.hashCode ^
      category.hashCode ^
      note.hashCode ^
      receiptImagePath.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'ExpenseItem(id: $id, merchantName: $merchantName, totalAmount: $totalAmount, date: $transactionDate, category: $category)';
  }
}
