import 'dart:math';
import 'package:flutter/material.dart';

/// Zero-dependency CustomPainter rendering a 7-day spending bar chart.
/// Paints rounded vertical bars and weekday labels (T2, T3, T4, T5, T6, T7, CN).
class WeeklyBarPainter extends CustomPainter {
  final List<double> weeklyAmounts; // Exactly 7 values: Mon..Sun
  final double progress; // 0.0 to 1.0 from AnimationController
  final int currentWeekdayIndex; // 0 (Mon) to 6 (Sun)
  final int? selectedIndex;
  final Color primaryColor;
  final Color activeBarColor;
  final Color inactiveBarColor;
  final Color labelColor;

  WeeklyBarPainter({
    required this.weeklyAmounts,
    required this.progress,
    required this.currentWeekdayIndex,
    this.selectedIndex,
    required this.primaryColor,
    required this.activeBarColor,
    required this.inactiveBarColor,
    required this.labelColor,
  });

  static const List<String> _weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  void paint(Canvas canvas, Size size) {
    const labelHeight = 22.0;
    final chartHeight = max(10.0, size.height - labelHeight);
    final count = weeklyAmounts.length;
    if (count == 0) return;

    final maxAmount = weeklyAmounts.reduce(max);
    final effectiveMax = maxAmount > 0 ? maxAmount : 1.0;

    final totalBarWidths = size.width / count;
    final barWidth = min(22.0, totalBarWidths * 0.55);

    for (int i = 0; i < count; i++) {
      final amount = weeklyAmounts[i];
      final isToday = i == currentWeekdayIndex;
      final isSelected = selectedIndex == i;

      final normalizedRatio = (amount / effectiveMax).clamp(0.0, 1.0);
      final rawBarHeight = normalizedRatio * chartHeight * progress;
      final barHeight = max(4.0, rawBarHeight); // Minimum baseline pill

      final centerX = (i + 0.5) * totalBarWidths;
      final left = centerX - (barWidth / 2);
      final top = chartHeight - barHeight;

      final barRect = Rect.fromLTWH(left, top, barWidth, barHeight);
      final roundedRect = RRect.fromRectAndCorners(
        barRect,
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      );

      // Bar Paint
      final paint = Paint()..style = PaintingStyle.fill;
      if (isSelected) {
        paint.color = activeBarColor;
      } else if (isToday) {
        paint.color = primaryColor;
      } else if (amount > 0) {
        paint.color = primaryColor.withValues(alpha: 0.5);
      } else {
        paint.color = inactiveBarColor;
      }

      canvas.drawRRect(roundedRect, paint);

      // Draw floating tooltip amount above selected bar
      if (isSelected && amount > 0) {
        final compactText = amount >= 1000000
            ? '${(amount / 1000000).toStringAsFixed(1)}Tr'
            : '${(amount / 1000).round()}k';
        final tooltipSpan = TextSpan(
          text: compactText,
          style: TextStyle(
            color: activeBarColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        );
        final tooltipPainter = TextPainter(text: tooltipSpan, textDirection: TextDirection.ltr);
        tooltipPainter.layout();
        tooltipPainter.paint(
          canvas,
          Offset(centerX - (tooltipPainter.width / 2), max(0.0, top - 15)),
        );
      }

      // Draw Weekday Label (T2..CN)
      final label = _weekdayLabels[i];
      final textSpan = TextSpan(
        text: label,
        style: TextStyle(
          color: isToday || isSelected ? primaryColor : labelColor,
          fontSize: 11,
          fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(centerX - (tp.width / 2), chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant WeeklyBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.weeklyAmounts != weeklyAmounts ||
        oldDelegate.currentWeekdayIndex != currentWeekdayIndex ||
        oldDelegate.primaryColor != primaryColor;
  }
}
