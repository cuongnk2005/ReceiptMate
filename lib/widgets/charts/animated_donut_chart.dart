import 'package:flutter/material.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/category_expense.dart';
import 'category_donut_painter.dart';

/// Animated Donut Chart widget backed by zero-dependency CustomPainter.
/// Provides center summary and interactive slice selection.
class AnimatedDonutChart extends StatefulWidget {
  final List<CategoryExpense> slices;
  final double totalAmount;

  const AnimatedDonutChart({
    super.key,
    required this.slices,
    required this.totalAmount,
  });

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slices != widget.slices) {
      _controller.reset();
      _controller.forward();
      _selectedIndex = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emptyColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Canvas Donut Chart with Center Hole Info
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(200, 200),
                    painter: CategoryDonutPainter(
                      slices: widget.slices,
                      progress: _animation.value,
                      selectedIndex: _selectedIndex,
                      emptyColor: emptyColor,
                    ),
                  );
                },
              ),
              // Center Label
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedIndex != null && _selectedIndex! < widget.slices.length
                          ? widget.slices[_selectedIndex!].categoryName
                          : 'Tổng chi tiêu',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedIndex != null && _selectedIndex! < widget.slices.length
                          ? CurrencyFormatter.formatCompact(widget.slices[_selectedIndex!].amount)
                          : CurrencyFormatter.formatCompact(widget.totalAmount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _selectedIndex != null && _selectedIndex! < widget.slices.length
                            ? widget.slices[_selectedIndex!].color
                            : theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_selectedIndex != null && _selectedIndex! < widget.slices.length) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${(widget.slices[_selectedIndex!].percentage * 100).toStringAsFixed(1)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Interactive Legend Items
        if (widget.slices.isNotEmpty)
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(widget.slices.length, (index) {
              final slice = widget.slices[index];
              final isSelected = _selectedIndex == index;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIndex = isSelected ? null : index;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? slice.color.withValues(alpha: 0.18)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? slice.color : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: slice.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        slice.categoryName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(slice.percentage * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }
}
