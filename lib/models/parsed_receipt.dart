import 'package:flutter/foundation.dart';

/// Immutable model representing auto-suggested fields extracted from receipt OCR.
/// Adheres strictly to the "Never Trust OCR Blindly" principle (suggestions only).
@immutable
class ParsedReceipt {
  final String? merchantName;
  final double? totalAmount;
  final DateTime? transactionDate;
  final String? suggestedCategory;
  final String rawText;
  final double confidenceScore; // 0.0 to 1.0
  final String? imagePath;

  const ParsedReceipt({
    this.merchantName,
    this.totalAmount,
    this.transactionDate,
    this.suggestedCategory,
    required this.rawText,
    this.confidenceScore = 0.0,
    this.imagePath,
  });

  /// Factory for an empty or failed scan result
  factory ParsedReceipt.empty({String? imagePath}) {
    return ParsedReceipt(
      rawText: '',
      confidenceScore: 0.0,
      imagePath: imagePath,
    );
  }

  /// Whether the heuristics successfully extracted the core financial figures
  bool get hasHighConfidence =>
      merchantName != null && totalAmount != null && totalAmount! > 0;

  @override
  String toString() {
    return 'ParsedReceipt(merchant: $merchantName, amount: $totalAmount, date: $transactionDate, category: $suggestedCategory, confidence: $confidenceScore)';
  }
}
