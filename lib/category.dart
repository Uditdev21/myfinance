import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myfinance/AppDrawer.dart';
import 'package:myfinance/data/categoryProvider.dart';
import 'package:myfinance/data/transactionProvider.dart';

class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final TextEditingController categoryController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Categories")),
      drawer: AppDrawer(),
      body: categories.when(
        data: (data) => Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two cards per row
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.5, // Aspect ratio to make cards wider
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final category = data[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final isInUse = await ref
                              .read(transactionServiceProvider)
                              .isCategoryInUse(category);
                          if (isInUse) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Category '$category' is in use and cannot be deleted."),
                              ),
                            );
                          } else {
                            ref
                                .read(firestoreServiceProvider)
                                .deleteCategory(category);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addCategoryDialog(context, ref, categoryController),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addCategoryDialog(
      BuildContext context, WidgetRef ref, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Category"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Category Name"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(firestoreServiceProvider).addCategory(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
