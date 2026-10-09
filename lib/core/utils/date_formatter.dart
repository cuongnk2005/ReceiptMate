import 'package:intl/intl.dart';

/// Date formatting utilities for ReceiptMate
class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MM/yyyy');
  static final DateFormat _friendlyMonthFormat = DateFormat("'Tháng' MM, yyyy");

  /// Standard Vietnamese date: 09/10/2026
  static String format(DateTime date) => _dateFormat.format(date);

  /// Date and Time: 09/10/2026 14:30
  static String formatWithTime(DateTime date) => _dateTimeFormat.format(date);

  /// Month & Year: Tháng 10, 2026
  static String formatMonthYear(DateTime date) => _friendlyMonthFormat.format(date);

  /// MM/yyyy
  static String formatShortMonth(DateTime date) => _monthYearFormat.format(date);

  /// Friendly relative label: "Hôm nay", "Hôm qua", or "dd/MM/yyyy"
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(targetDate).inDays;
    if (difference == 0) {
      return 'Hôm nay';
    } else if (difference == 1) {
      return 'Hôm qua';
    } else {
      return _dateFormat.format(date);
    }
  }

  /// Get day of week abbreviation in Vietnamese (T2, T3, T4, T5, T6, T7, CN)
  static String getWeekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'T2';
      case DateTime.tuesday:
        return 'T3';
      case DateTime.wednesday:
        return 'T4';
      case DateTime.thursday:
        return 'T5';
      case DateTime.friday:
        return 'T6';
      case DateTime.saturday:
        return 'T7';
      case DateTime.sunday:
        return 'CN';
      default:
        return '';
    }
  }
}
