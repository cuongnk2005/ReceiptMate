import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_mate/main.dart';

void main() {
  testWidgets('ReceiptMateApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ReceiptMateApp(),
      ),
    );

    // Verify app title displays on dashboard
    expect(find.text('ReceiptMate'), findsOneWidget);
  });
}
