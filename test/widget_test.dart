import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfinance/transation.dart';

void main() {
  testWidgets('Transaction Screen UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: TransactionScreen()),
      ),
    );

    // Check if AppBar title is present
    expect(find.text('Transactions'), findsOneWidget);

    // Check if FloatingActionButton is present
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Tap on Floating Action Button and check if the dialog appears
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(find.text('Add Transaction'), findsOneWidget);
  });
}
