import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/data/transactionModel.dart';

void main() {
  test('TransactionModel should store correct values', () {
    final testDate = DateTime(2025, 3, 19);
    final transaction = TransactionModel(
      id: "test1",
      amount: 200.0,
      type: "expense",
      categoryId: "Food",
      date: Timestamp.fromDate(testDate), // Store as Firestore Timestamp
      title: 'Dinner',
    );

    expect(transaction.id, "test1");
    expect(transaction.amount, 200.0);
    expect(transaction.type, "expense");
    expect(transaction.categoryId, "Food");
    expect(transaction.date, isA<Timestamp>()); // Ensure it's a Timestamp
    expect(transaction.date.toDate(),
        testDate); // Convert to DateTime before comparing
    expect(transaction.title, "Dinner");
  });
}
