import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());
final categoriesProvider = StreamProvider<List<String>>((ref) {
  return ref.read(firestoreServiceProvider).getCategories();
});

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  Stream<List<String>> getCategories() {
    return _db
        .collection("users")
        .doc(_userId)
        .collection("categories")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Future<void> addCategory(String name) async {
    await _db
        .collection("users")
        .doc(_userId)
        .collection("categories")
        .doc(name)
        .set({});
  }

  Future<void> deleteCategory(String name) async {
    await _db
        .collection("users")
        .doc(_userId)
        .collection("categories")
        .doc(name)
        .delete();
  }
}
