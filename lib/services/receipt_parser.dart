import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../core/constants/app_constants.dart';
import '../models/parsed_receipt.dart';

/// Heuristic-based Vietnamese receipt parser.
/// Extracts total amount, transaction date, merchant name, and suggests categories.
class ReceiptParser {
  ReceiptParser._();

  // Known Vietnamese retail & F&B brands and their default category mappings
  static final Map<String, String> _knownBrands = {
    'highlands': AppConstants.catFood,
    'phúc long': AppConstants.catFood,
    'phuc long': AppConstants.catFood,
    'the coffee house': AppConstants.catFood,
    'starbucks': AppConstants.catFood,
    'katinat': AppConstants.catFood,
    'trung nguyên': AppConstants.catFood,
    'trung nguyen': AppConstants.catFood,
    'tocotoco': AppConstants.catFood,
    'gong cha': AppConstants.catFood,
    'lotteria': AppConstants.catFood,
    'kfc': AppConstants.catFood,
    'jollibee': AppConstants.catFood,
    'mcdonald': AppConstants.catFood,
    'pizza company': AppConstants.catFood,
    'pizza hut': AppConstants.catFood,
    'haidilao': AppConstants.catFood,
    'golden gate': AppConstants.catFood,
    'gogi': AppConstants.catFood,
    'kichi': AppConstants.catFood,
    'winmart': AppConstants.catShopping,
    'circle k': AppConstants.catShopping,
    'family mart': AppConstants.catShopping,
    'familymart': AppConstants.catShopping,
    'gs25': AppConstants.catShopping,
    '7-eleven': AppConstants.catShopping,
    'co.opmart': AppConstants.catShopping,
    'coopmart': AppConstants.catShopping,
    'bách hóa xanh': AppConstants.catShopping,
    'bach hoa xanh': AppConstants.catShopping,
    'ministop': AppConstants.catShopping,
    'emart': AppConstants.catShopping,
    'big c': AppConstants.catShopping,
    'go!': AppConstants.catShopping,
    'lotte mart': AppConstants.catShopping,
    'pharmacity': AppConstants.catShopping,
    'long châu': AppConstants.catShopping,
    'long chau': AppConstants.catShopping,
    'grab': AppConstants.catTransport,
    'be': AppConstants.catTransport,
    'xanh sm': AppConstants.catTransport,
    'petrolimex': AppConstants.catTransport,
    'cây xăng': AppConstants.catTransport,
    'evn': AppConstants.catUtilities,
    'viettel': AppConstants.catUtilities,
    'vnpt': AppConstants.catUtilities,
    'fpt': AppConstants.catUtilities,
    'cấp nước': AppConstants.catUtilities,
  };

  // Keywords indicating total payable amount
  static final RegExp _totalKeywordRegex = RegExp(
    r'(tổng\s*cộng|tong\s*cong|thanh\s*toán|thanh\s*toan|tổng\s*tiền|tong\s*tien|khách\s*phải\s*trả|khach\s*tra|amount\s*due|grand\s*total|total|phải\s*thu|cong\s*tien)',
    caseSensitive: false,
  );

  // Numbers that could represent currency in VND (e.g. 150.000, 150,000, 45k)
  static final RegExp _currencyRegex = RegExp(
    r'(\d{1,3}(?:[.,]\d{3})+(?:\.\d{2})?|\d+[kK]|\b\d{4,9}\b)',
  );

  // Date formats: dd/MM/yyyy, dd-MM-yyyy, yyyy-MM-dd
  static final RegExp _dateRegex = RegExp(
    r'\b(?:(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})|(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2}))\b',
  );

  // Common boilerplate lines to ignore when extracting merchant name
  static final List<String> _boilerplateKeywords = [
    'hóa đơn', 'hoa don', 'phiếu thanh toán', 'phieu thanh toan',
    'receipt', 'bill', 'invoice', 'welcome', 'xin cảm ơn',
    'xin cam on', 'cửa hàng', 'chi nhánh', 'phiếu tính tiền',
    'order', 'bàn:', 'ban:', 'thu ngân:', 'nhân viên:',
  ];

  /// Main entry point to parse RecognizedText into a ParsedReceipt
  static ParsedReceipt parse(RecognizedText recognizedText, {String? imagePath}) {
    final rawText = recognizedText.text;
    final lines = <String>[];

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final text = line.text.trim();
        if (text.isNotEmpty) {
          lines.add(text);
        }
      }
    }

    if (lines.isEmpty) {
      return ParsedReceipt.empty(imagePath: imagePath);
    }

    // 1. Extract Merchant & Suggested Category
    final (merchantName, suggestedCategory) = _extractMerchant(lines);

    // 2. Extract Total Amount
    final totalAmount = _extractTotalAmount(lines);

    // 3. Extract Date
    final transactionDate = _extractDate(lines);

    // 4. Calculate confidence score
    double confidence = 0.0;
    if (totalAmount != null) confidence += 0.5;
    if (merchantName != null) confidence += 0.3;
    if (transactionDate != null) confidence += 0.2;

    return ParsedReceipt(
      merchantName: merchantName,
      totalAmount: totalAmount,
      transactionDate: transactionDate ?? DateTime.now(),
      suggestedCategory: suggestedCategory ?? AppConstants.catFood,
      rawText: rawText,
      confidenceScore: confidence,
      imagePath: imagePath,
    );
  }

  /// Heuristically find the merchant name
  static (String?, String?) _extractMerchant(List<String> lines) {
    // Stage A: Match against known brand dictionary
    for (final line in lines.take(10)) {
      final lower = line.toLowerCase();
      for (final entry in _knownBrands.entries) {
        if (lower.contains(entry.key)) {
          return (line, entry.value);
        }
      }
    }

    // Stage B: Fallback - find first prominent line in the header (lines 0..4)
    for (final line in lines.take(5)) {
      final lower = line.toLowerCase();
      final isBoilerplate = _boilerplateKeywords.any((b) => lower.contains(b));
      final hasDigitOnly = RegExp(r'^\d+$').hasMatch(line);

      if (!isBoilerplate && !hasDigitOnly && line.length >= 3) {
        return (line, null);
      }
    }

    return (null, null);
  }

  /// Heuristically extract the total amount payable
  static double? _extractTotalAmount(List<String> lines) {
    // Strategy 1: Check lines matching total keywords
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (_totalKeywordRegex.hasMatch(line)) {
        // Try to parse amount from the same line
        final amountInLine = parseVndAmount(line);
        if (amountInLine != null) return amountInLine;

        // Try next 2 lines if amount is placed below keyword
        for (int next = 1; next <= 2 && (i + next) < lines.length; next++) {
          final amountInNextLine = parseVndAmount(lines[i + next]);
          if (amountInNextLine != null) return amountInNextLine;
        }
      }
    }

    // Strategy 2: Fallback - look through bottom 60% of lines for highest valid amount
    final startIndex = (lines.length * 0.4).floor();
    double highestAmount = 0.0;

    for (int i = startIndex; i < lines.length; i++) {
      final amount = parseVndAmount(lines[i]);
      if (amount != null && amount > highestAmount && amount <= 50000000.0) {
        highestAmount = amount;
      }
    }

    return highestAmount > 0 ? highestAmount : null;
  }

  /// Parses text into clean VND amount
  static double? parseVndAmount(String text) {
    final matches = _currencyRegex.allMatches(text);
    if (matches.isEmpty) return null;

    double? lastValid;
    for (final match in matches) {
      String raw = match.group(0)!.trim();

      // Case 1: Suffix 'k' or 'K' (e.g., '45k' -> 45000.0)
      if (raw.toLowerCase().endsWith('k')) {
        final numPart = raw.substring(0, raw.length - 1);
        final val = double.tryParse(numPart);
        if (val != null && val > 0) {
          lastValid = val * 1000.0;
        }
        continue;
      }

      // Case 2: Thousand separators (dots or commas) -> remove all '.' and ','
      raw = raw.replaceAll('.', '').replaceAll(',', '');
      final val = double.tryParse(raw);

      // Validation: Discard unrealistic numbers (< 1.000 VND or > 100.000.000 VND)
      if (val != null && val >= 1000.0 && val <= 100000000.0) {
        lastValid = val;
      }
    }

    return lastValid;
  }

  /// Heuristically extract transaction date
  static DateTime? _extractDate(List<String> lines) {
    for (final line in lines) {
      final match = _dateRegex.firstMatch(line);
      if (match != null) {
        try {
          if (match.group(3) != null) {
            // dd/MM/yyyy
            final day = int.parse(match.group(1)!);
            final month = int.parse(match.group(2)!);
            final year = int.parse(match.group(3)!);
            if (month >= 1 && month <= 12 && day >= 1 && day <= 31 && year >= 2000 && year <= 2050) {
              return DateTime(year, month, day);
            }
          } else if (match.group(4) != null) {
            // yyyy/MM/dd
            final year = int.parse(match.group(4)!);
            final month = int.parse(match.group(5)!);
            final day = int.parse(match.group(6)!);
            if (month >= 1 && month <= 12 && day >= 1 && day <= 31 && year >= 2000 && year <= 2050) {
              return DateTime(year, month, day);
            }
          }
        } catch (_) {
          continue;
        }
      }
    }
    return null;
  }
}
