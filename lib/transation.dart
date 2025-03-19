import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myfinance/AppDrawer.dart';
import 'package:myfinance/data/transactionModel.dart';
import 'package:myfinance/data/transactionProvider.dart';
import 'package:myfinance/data/categoryProvider.dart';

class TransactionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Transactions")),
      drawer: AppDrawer(),
      body: transactions.when(
        data: (data) => ListView(
          children: data
              .map((tx) => Card(
                    elevation: 2,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            tx.type == "income" ? Colors.green : Colors.red,
                        child: Icon(
                          tx.type == "income"
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        tx.categoryId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        tx.date.toDate().toString().split('.')[0],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "\$${tx.amount.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: tx.type == "income"
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => ref
                                .read(transactionServiceProvider)
                                .deleteTransaction(tx.id),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTransactionDialog(context, ref, categories),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addTransactionDialog(BuildContext context, WidgetRef ref,
      AsyncValue<List<String>> categories) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    String selectedType = "expense";
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add Transaction"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Amount"),
                ),
                DropdownButton<String>(
                  value: selectedType,
                  items: ["income", "expense"].map((String value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedType = val!;
                    });
                  },
                ),
                categories.when(
                  data: (categoryList) {
                    if (selectedCategory == null && categoryList.isNotEmpty) {
                      selectedCategory = categoryList.first;
                    }
                    return DropdownButton<String>(
                      value: selectedCategory,
                      hint: const Text("Select Category"),
                      items: categoryList.map((String category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCategory = val!;
                        });
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => Text("Error loading categories"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  if (selectedCategory == null ||
                      titleController.text.isEmpty ||
                      amountController.text.isEmpty) {
                    return;
                  }

                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    return;
                  }

                  final transaction = TransactionModel(
                    id: "", // ID should be auto-generated
                    title: titleController.text,
                    amount: amount,
                    type: selectedType,
                    categoryId: selectedCategory!,
                    date: Timestamp.now(),
                  );

                  ref
                      .read(transactionServiceProvider)
                      .addTransaction(transaction);
                  Navigator.pop(context);
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      ),
    );
  }
}
