import 'package:flutter/material.dart';

/// Centralized color palette for ReceiptMate.
/// Strictly follows Material 3 principles and uses VKU Navy as the brand seed.
class AppColors {
  AppColors._();

  // Brand Seed & Primaries
  static const Color primary = Color(0xFF2C4570); // VKU Navy
  static const Color primaryContainer = Color(0xFFD9E2FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF001944);

  // Secondary & Accents
  static const Color secondary = Color(0xFF00897B); // Mint / Teal accent
  static const Color secondaryContainer = Color(0xFFB2DFDB);
  static const Color tertiary = Color(0xFFE65100); // Amber / Orange accent

  // Neutral Backgrounds & Surfaces
  static const Color lightBackground = Color(0xFFF8F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFF1F3F9);
  static const Color lightBorder = Color(0xFFE2E8F0);

  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceContainer = Color(0xFF283548);
  static const Color darkBorder = Color(0xFF334155);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Category Colors (Curated distinct hues for charts & badges)
  static const Color categoryFood = Color(0xFFFF6B6B); // Đỏ san hô - Ăn uống
  static const Color categoryShopping = Color(0xFF4D96FF); // Xanh dương - Mua sắm
  static const Color categoryTransport = Color(0xFFFFD93D); // Vàng - Di chuyển
  static const Color categoryUtilities = Color(0xFF6BCB77); // Xanh lá - Tiện ích
  static const Color categoryOther = Color(0xFF9D4EDD); // Tím - Khác

  /// Map category key to its distinct color
  static Color getCategoryColor(String categoryKey) {
    switch (categoryKey.toLowerCase()) {
      case 'food':
        return categoryFood;
      case 'shopping':
        return categoryShopping;
      case 'transport':
        return categoryTransport;
      case 'utilities':
        return categoryUtilities;
      case 'other':
      default:
        return categoryOther;
    }
  }
}
