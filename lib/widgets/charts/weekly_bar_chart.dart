import 'package:flutter/material.dart';
import '../../core/utils/currency_formatter.dart';
import 'weekly_bar_painter.dart';

/// Weekly spending bar chart with animation and interactive day selection.
class WeeklyBarChart extends StatefulWidget {
  final List<double> weeklyAmounts; // 7 values for Mon..Sun

  const WeeklyBarChart({
    super.key,
    required this.weeklyAmounts,
  });

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  int? _selectedIndex;

  static const List<String> _fullDayNames = [
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
    'Chủ Nhật',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant WeeklyBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weeklyAmounts != widget.weeklyAmounts) {
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

  void _handleTapDown(TapDownDetails details, BoxConstraints constraints) {
    final count = widget.weeklyAmounts.length;
    if (count == 0) return;
    final columnWidth = constraints.maxWidth / count;
    final tappedIndex = (details.localPosition.dx / columnWidth).floor().clamp(0, count - 1);

    setState(() {
      _selectedIndex = _selectedIndex == tappedIndex ? null : tappedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final todayIndex = (now.weekday - 1).clamp(0, 6);

    final totalWeek = widget.weeklyAmounts.fold<double>(0.0, (s, a) => s + a);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with weekly total or selected day amount
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedIndex != null
                      ? _fullDayNames[_selectedIndex!]
                      : 'Chi tiêu 7 ngày qua',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedIndex != null
                      ? CurrencyFormatter.format(widget.weeklyAmounts[_selectedIndex!])
                      : CurrencyFormatter.format(totalWeek),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _selectedIndex != null
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (_selectedIndex != null)
              TextButton(
                onPressed: () => setState(() => _selectedIndex = null),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Xem cả tuần', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // 7-day Bar Canvas
        LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTapDown: (details) => _handleTapDown(details, constraints),
              child: SizedBox(
                height: 130,
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(constraints.maxWidth, 130),
                      painter: WeeklyBarPainter(
                        weeklyAmounts: widget.weeklyAmounts,
                        progress: _animation.value,
                        currentWeekdayIndex: todayIndex,
                        selectedIndex: _selectedIndex,
                        primaryColor: theme.colorScheme.primary,
                        activeBarColor: theme.colorScheme.secondary,
                        inactiveBarColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                        labelColor: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
