// This is a basic Flutter widget test for CureLedger.

import 'package:flutter_test/flutter_test.dart';

import 'package:cure_ledger/src/app/app.dart';

void main() {
  testWidgets('CureLedger app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CureLedgerApp());

    // Verify that the app loads and shows the title
    expect(find.text('CureLedger'), findsOneWidget);
  });
}
