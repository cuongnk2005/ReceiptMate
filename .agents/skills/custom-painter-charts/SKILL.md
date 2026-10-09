---
name: custom-painter-charts
description: >-
  Mathematical formulas, architecture, and best practices for creating zero-dependency
  high-performance animated charts using Flutter CustomPainter and AnimationController.
  Activate this skill when creating or modifying Donut charts, Bar charts, Canvas painters,
  or chart animation controllers in ReceiptMate.
---

# Flutter CustomPainter Charting Skill

This skill guides the construction of custom animated visualizations using Flutter's built-in `CustomPainter` and `AnimationController` for **ReceiptMate**, completely free of third-party charting libraries (`fl_chart`, `syncfusion`).

---

## 1. Category Donut Chart (`CategoryDonutPainter`)

### 1.1 Geometry & Mathematics
- **Center:** `Offset(size.width / 2, size.height / 2)`
- **Radius:** `(min(size.width, size.height) / 2) - (strokeWidth / 2)`
- **Sweep Angle per Category:**
  $$\theta_{cat} = \left(\frac{S_{cat}}{S_{total}}\right) \times 2\pi \times \text{animationProgress}$$

### 1.2 Painter Implementation
```dart
import 'dart:math';
import 'package:flutter/material.dart';

class CategoryDonutPainter extends CustomPainter {
  final List<CategorySlice> slices;
  final double progress; // 0.0 to 1.0 from AnimationController
  final int? selectedIndex;

  CategoryDonutPainter({
    required this.slices,
    required this.progress,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) {
      _paintEmptyCircle(canvas, size);
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = min(size.width, size.height) / 2 - 20.0;
    double startAngle = -pi / 2; // Start from top (12 o'clock)

    final total = slices.fold<double>(0.0, (sum, s) => sum + s.amount);
    if (total == 0) {
      _paintEmptyCircle(canvas, size);
      return;
    }

    for (int i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final sweepAngle = (slice.amount / total) * 2 * pi * progress;
      final isSelected = selectedIndex == i;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 28.0 : 22.0
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(
        center: center,
        radius: isSelected ? baseRadius + 4 : baseRadius,
      );

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  void _paintEmptyCircle(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16.0;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 - 20, paint);
  }

  @override
  bool shouldRepaint(covariant CategoryDonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.slices != slices;
  }
}
```

---

## 2. Weekly Spending Bar Chart (`WeeklyBarPainter`)

### 2.1 Geometry & Scaling
- Calculate highest spending across 7 days: $Amount_{max} = \max(Amount_0, \dots, Amount_6)$.
- Column height: $Height_i = \left(\frac{Amount_i}{\max(Amount_{max}, 1.0)}\right) \times MaxHeight \times \text{progress}$.
- Ensure minimum visible height of 4px for zero-spending days.
- Draw rounded bar: `RRect.fromRectAndRadius(rect, Radius.circular(6))`.

### 2.2 Text Labels via `TextPainter`
Render weekday labels (T2, T3, T4, T5, T6, T7, CN) directly beneath each bar:
```dart
void _drawLabel(Canvas canvas, String label, Offset position, Color color) {
  final textSpan = TextSpan(
    text: label,
    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
  );
  final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
  tp.layout();
  tp.paint(canvas, Offset(position.dx - tp.width / 2, position.dy));
}
```

---

## 3. High-Performance Canvas Best Practices

1. **`shouldRepaint` Accuracy:**
   - Only return `true` when animation `progress` or dataset instances actually change. Never return `true` unconditionally.
2. **Controller Lifecycle:**
   - Always initialize `AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))` in `initState()`.
   - Forward with smooth easing: `_controller.forward()`.
   - Always call `_controller.dispose()` in `dispose()`.
3. **Responsive Size Clamping:**
   - Always wrap Canvas inside `LayoutBuilder` or `SizedBox` with explicit constraints to avoid negative radii or infinite canvas dimensions.
