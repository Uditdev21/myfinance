import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myfinance/data/transactionModel.dart';

final transactionServiceProvider = Provider((ref) => TransactionService());
final transactionProvider = StreamProvider<List<TransactionModel>>((ref) {
  return ref.read(transactionServiceProvider).getTransactions();
});

final last5TransactionsProvider = StreamProvider((ref) {
  final service = ref.read(transactionServiceProvider);
  return service.getLast5Transactions();
});

final last30DaysIncomeExpenditureProvider = StreamProvider((ref) {
  final service = ref.read(transactionServiceProvider);
  return service.getLast30DaysIncomeAndExpenditure();
});

class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  // 🔹 Get Transactions
  Stream<List<TransactionModel>> getTransactions() {
    return _db
        .collection("users")
        .doc(_userId)
        .collection("transactions")
        .orderBy("date", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  // 🔹 Add Transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    await _db
        .collection("users")
        .doc(_userId)
        .collection("transactions")
        .add(transaction.toMap());
  }

  // 🔹 Delete Transaction
  Future<void> deleteTransaction(String transactionId) async {
    await _db
        .collection("users")
        .doc(_userId)
        .collection("transactions")
        .doc(transactionId)
        .delete();
  }

  Future<bool> isCategoryInUse(String categoryName) async {
    final transactions = await _db
        .collection("users")
        .doc(_userId)
        .collection("transactions")
        .where("categoryId", isEqualTo: categoryName)
        .get();
    return transactions.docs.isNotEmpty;
  }

  Stream<List<Map<String, dynamic>>> getLast5Transactions() {
    return _db
        .collection("users")
        .doc(_userId)
        .collection("transactions")
        .orderBy("date", descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<Map<String, double>> getLast30DaysIncomeAndExpenditure() {
    final DateTime now = DateTime.now();
    final DateTime last30Days = now.subtract(Duration(days: 30));
    return _db
        .collection("users")
        .doc(_userId)
        .collection("transactions")
        .where("date", isGreaterThanOrEqualTo: Timestamp.fromDate(last30Days))
        .snapshots()
        .map((snapshot) {
      double income = 0;
      double expenditure = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data["type"] == "income") {
          income += (data["amount"] ?? 0).toDouble();
        } else if (data["type"] == "expense") {
          expenditure += (data["amount"] ?? 0).toDouble();
        }
      }
      return {"income": income, "expenditure": expenditure};
    });
  }
}
