import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type; // "income" or "expense"
  final String categoryId;
  final Timestamp date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "amount": amount,
      "type": type,
      "categoryId": categoryId,
      "date": date,
    };
  }

  /// Create a model instance from Firestore document
  static TransactionModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TransactionModel(
      id: doc.id,
      title: data["title"] ?? "Untitled", // Default to avoid null errors
      amount: (data["amount"] as num?)?.toDouble() ?? 0.0, // Ensure double type
      type: data["type"] ?? "expense", // Default value
      categoryId: data["categoryId"] ?? "",
      date: data["date"] as Timestamp? ?? Timestamp.now(),
    );
  }

  /// Create a new instance with updated values
  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? type,
    String? categoryId,
    Timestamp? date,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
    );
  }
}
