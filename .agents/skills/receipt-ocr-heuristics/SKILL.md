---
name: receipt-ocr-heuristics
description: >-
  Specialized runbook and heuristic algorithms for implementing On-Device Offline OCR
  using Google ML Kit (google_mlkit_text_recognition) and Vietnamese currency/receipt
  parsing heuristics (amount normalization, merchant extraction, date extraction, and
  fail-safe fallbacks). Activate this skill when working on receipt scanning, OCR processing,
  regex parsing, or the Review & Verification screen.
---

# Receipt OCR & Vietnamese Heuristics Skill

This skill guides the implementation of offline on-device text recognition and Vietnamese receipt parsing for **ReceiptMate**, guaranteeing 100% offline functionality, fast processing (< 1.5s), and privacy.

---

## 1. On-Device OCR Pipeline (Google ML Kit)

```dart
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  late final TextRecognizer _textRecognizer;

  OcrService() {
    // Latin/Default script recognizer runs locally on device
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  Future<RecognizedText> processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    return await _textRecognizer.processImage(inputImage);
  }

  void dispose() {
    _textRecognizer.close();
  }
}
```

---

## 2. Vietnamese Receipt Heuristic Parser (`ReceiptParser`)

### 2.1 Keyword Patterns for Total Amount
Vietnamese receipts use specific phrases before or near the grand total:
```dart
static final RegExp _totalKeywordRegex = RegExp(
  r'(tổng\s*cộng|tong\s*cong|thanh\s*toán|thanh\s*toan|tổng\s*tiền|tong\s*tien|khách\s*phải\s*trả|khach\s*tra|amount\s*due|grand\s*total|total|phải\s*thu)',
  caseSensitive: false,
);
```

### 2.2 Currency Number Extraction & Normalization
Vietnamese currency formats often include: `150.000`, `150,000`, `150000`, `150.000 đ`, `150,000 VND`, or `45k`/`45K`.

```dart
static final RegExp _currencyRegex = RegExp(r'(\d{1,3}(?:[.,]\d{3})*(?:\.\d{2})?|\d+[kK])');

static double? parseVndAmount(String text) {
  final match = _currencyRegex.firstMatch(text);
  if (match == null) return null;

  String raw = match.group(0)!.trim();

  // Case 1: Suffix 'k' or 'K' (e.g., '65k' -> 65000.0)
  if (raw.toLowerCase().endsWith('k')) {
    final numPart = raw.substring(0, raw.length - 1);
    final val = double.tryParse(numPart);
    if (val != null) return val * 1000.0;
  }

  // Case 2: Thousand separators (dots or commas) -> remove all '.' and ','
  raw = raw.replaceAll('.', '').replaceAll(',', '');
  final amount = double.tryParse(raw);

  // Validation: Discard unrealistic numbers (< 1.000 VND)
  if (amount != null && amount >= 1000.0) {
    return amount;
  }
  return null;
}
```

### 2.3 Date Parsing Heuristic
Supports `dd/MM/yyyy`, `dd-MM-yyyy`, `yyyy-MM-dd`:
```dart
static final RegExp _dateRegex = RegExp(
  r'\b(?:(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})|(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2}))\b',
);

static DateTime? parseReceiptDate(String text) {
  final match = _dateRegex.firstMatch(text);
  if (match == null) return null;

  try {
    if (match.group(3) != null) {
      // dd/MM/yyyy format
      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final year = int.parse(match.group(3)!);
      return DateTime(year, month, day);
    } else if (match.group(4) != null) {
      // yyyy/MM/dd format
      final year = int.parse(match.group(4)!);
      final month = int.parse(match.group(5)!);
      final day = int.parse(match.group(6)!);
      return DateTime(year, month, day);
    }
  } catch (_) {
    return null;
  }
  return null;
}
```

### 2.4 Merchant Name Prediction
1. Match against known retail / F&B brands dictionary:
   `["WinMart", "Circle K", "Highlands Coffee", "Phúc Long", "Co.opmart", "GS25", "7-Eleven", "FamilyMart", "Bách Hóa Xanh", "Starbucks"]`
2. Fallback: inspect the first 3-5 text lines, filter out boilerplate words ("HÓA ĐƠN", "PHIẾU THANH TOÁN", "RECEIPT", "BILL", "WELCOME"), and pick the first uppercase or prominent line.

---

## 3. Mandatory Review & Verification Principle

> **GOLDEN RULE: "Never Trust OCR Blindly"**  
> Output from ML Kit & Heuristic Parser must ONLY be treated as Auto-Suggestions.  
> It is FORBIDDEN to auto-commit OCR results directly to the database.

- **Routing:** Always navigate from OCR scan to `ReviewScreen`.
- **User Agency:** Allow editing of all fields (`merchantName`, `totalAmount`, `transactionDate`, `category`, `note`).
- **Fail-Safe Fallback:** If total amount or merchant cannot be found with confidence, leave the field empty (`null`) and highlight it with a helper message for manual entry.
