import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_mate/core/utils/currency_formatter.dart';
import 'package:receipt_mate/core/utils/text_normalizer.dart';
import 'package:receipt_mate/services/receipt_parser.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('format produces Vietnamese standard currency string', () {
      expect(CurrencyFormatter.format(150000), '150.000 đ');
      expect(CurrencyFormatter.format(2500000), '2.500.000 đ');
      expect(CurrencyFormatter.format(45000, includeSymbol: false), '45.000');
    });

    test('formatCompact converts values correctly', () {
      expect(CurrencyFormatter.formatCompact(45000), '45k');
      expect(CurrencyFormatter.formatCompact(1500000), '1.5Tr');
      expect(CurrencyFormatter.formatCompact(2000000000), '2Tỷ');
    });

    test('parseUserInput correctly normalizes dots, commas, symbols, and k suffix', () {
      expect(CurrencyFormatter.parseUserInput('150.000 đ'), 150000.0);
      expect(CurrencyFormatter.parseUserInput('250,000 VND'), 250000.0);
      expect(CurrencyFormatter.parseUserInput('45k'), 45000.0);
      expect(CurrencyFormatter.parseUserInput('65K'), 65000.0);
      expect(CurrencyFormatter.parseUserInput('80000'), 80000.0);
    });
  });

  group('ReceiptParser Regex Tests', () {
    test('parseVndAmount extracts Vietnamese amounts accurately', () {
      expect(ReceiptParser.parseVndAmount('Tổng cộng: 150.000 đ'), 150000.0);
      expect(ReceiptParser.parseVndAmount('Thanh toán: 45k'), 45000.0);
      expect(ReceiptParser.parseVndAmount('Khách phải trả: 120,000'), 120000.0);
      expect(ReceiptParser.parseVndAmount('Total: 85.000 VND'), 85000.0);
    });
  });

  group('TextNormalizer Tests (Diacritic-insensitive)', () {
    test('matches correctly regardless of case and Vietnamese accents', () {
      expect(TextNormalizer.matches('Cà phê Highland', 'ca phe'), isTrue);
      expect(TextNormalizer.matches('Bánh mì Phúc Long', 'phuc long'), isTrue);
      expect(TextNormalizer.matches('Highlands Coffee', 'HIGHLANDS'), isTrue);
      expect(TextNormalizer.matches('Siêu thị WinMart+', 'winmart'), isTrue);
      expect(TextNormalizer.matches('Quán ăn Phở Bắc', 'pho bac'), isTrue);
      expect(TextNormalizer.matches('Highlands Coffee', 'starbucks'), isFalse);
    });
  });
}
