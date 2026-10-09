import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/category_expense.dart';

/// Zero-dependency CustomPainter rendering an animated donut chart with rounded caps.
/// Accurately computes sweep angles and handles selected slice highlighting.
class CategoryDonutPainter extends CustomPainter {
  final List<CategoryExpense> slices;
  final double progress; // 0.0 to 1.0 from AnimationController
  final int? selectedIndex;
  final Color emptyColor;

  CategoryDonutPainter({
    required this.slices,
    required this.progress,
    this.selectedIndex,
    this.emptyColor = const Color(0xFFE2E8F0),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = (min(size.width, size.height) / 2) - 16.0;

    if (slices.isEmpty) {
      _paintEmptyCircle(canvas, center, baseRadius);
      return;
    }

    final total = slices.fold<double>(0.0, (sum, s) => sum + s.amount);
    if (total <= 0) {
      _paintEmptyCircle(canvas, center, baseRadius);
      return;
    }

    double startAngle = -pi / 2; // Start from 12 o'clock

    // If single slice takes 100%, render a full circle
    if (slices.length == 1) {
      final paint = Paint()
        ..color = slices.first.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24.0 * progress
        ..strokeCap = StrokeCap.butt;
      canvas.drawCircle(center, baseRadius, paint);
      return;
    }

    for (int i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final sweepAngle = (slice.amount / total) * 2 * pi * progress;
      final isSelected = selectedIndex == i;

      if (sweepAngle <= 0.001) continue;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 26.0 : 20.0
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(
        center: center,
        radius: isSelected ? baseRadius + 3 : baseRadius,
      );

      // Slight padding between segments when multiple slices exist
      final effectiveSweep = max(0.01, sweepAngle - 0.04);
      canvas.drawArc(rect, startAngle + 0.02, effectiveSweep, false, paint);

      startAngle += sweepAngle;
    }
  }

  void _paintEmptyCircle(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = emptyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CategoryDonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.slices != slices ||
        oldDelegate.emptyColor != emptyColor;
  }
}
