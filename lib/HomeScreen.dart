import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myfinance/AppDrawer.dart';
import 'package:myfinance/data/categoryProvider.dart';
import 'package:myfinance/data/transactionModel.dart';
import 'package:myfinance/data/transactionProvider.dart';
// import 'package:uuid/uuid.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final transactions = ref.watch(last5TransactionsProvider);
    final incomeExpenditure = ref.watch(last30DaysIncomeExpenditureProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Finance Tracker")),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Income and Expenditure Section
            incomeExpenditure.when(
              data: (data) => Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Last 30 Days",
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text("Income: ₹ ${data['income']}",
                          style: const TextStyle(
                              color: Colors.green, fontSize: 18)),
                      Text("Expenditure:  ₹ ${data['expenditure']}",
                          style:
                              const TextStyle(color: Colors.red, fontSize: 18)),
                      Text(
                          "Net balance: ₹ ${data['income']! - data['expenditure']!}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 18))
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Text("Error loading finance data",
                  style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 16),

            // Last 5 Transactions
            transactions.when(
              data: (data) => Card(
                elevation: 3,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Last 5 Transactions",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    ...data.map((tx) => ListTile(
                          title: Text("${tx['title']}",
                              style: TextStyle(
                                  color: tx['type'] == "income"
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(tx['categoryId'] ?? "No Category",
                              style: TextStyle(
                                  color: tx['type'] == "income"
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          trailing: Text(
                            "₹ ${tx['amount'].toString()}",
                            style: TextStyle(
                                color: tx['type'] == "income"
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Text("Error loading transactions",
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
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
