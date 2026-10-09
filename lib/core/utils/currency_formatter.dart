import 'package:intl/intl.dart';

/// Utility class for formatting Vietnamese currency (VND)
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vndFormat = NumberFormat('#,###', 'vi_VN');

  /// Format double to Vietnamese currency display: e.g., `150.000 đ`
  static String format(double amount, {bool includeSymbol = true}) {
    final formatted = _vndFormat.format(amount.round());
    return includeSymbol ? '$formatted đ' : formatted;
  }

  /// Compact representation for charts or small badges: e.g. `150K`, `1.5Tr`, `2.4Tỷ`
  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      final value = (amount / 1000000000).toStringAsFixed(1).replaceAll('.0', '');
      return '${value}Tỷ';
    } else if (amount >= 1000000) {
      final value = (amount / 1000000).toStringAsFixed(1).replaceAll('.0', '');
      return '${value}Tr';
    } else if (amount >= 1000) {
      final value = (amount / 1000).toStringAsFixed(0);
      return '${value}k';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  /// Parses text input to pure VND double, stripping all separators (.,đ,VND,spaces)
  static double? parseUserInput(String text) {
    String clean = text
        .replaceAll('đ', '')
        .replaceAll('VND', '')
        .replaceAll('vnd', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '');

    if (clean.toLowerCase().endsWith('k')) {
      final numPart = clean.substring(0, clean.length - 1);
      final val = double.tryParse(numPart);
      return val != null ? val * 1000.0 : null;
    }

    return double.tryParse(clean);
  }
}
