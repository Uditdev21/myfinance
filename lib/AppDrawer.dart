import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myfinance/HomeScreen.dart';
import 'package:myfinance/auth/authProvides.dart';
import 'package:myfinance/auth/loginScreen.dart';
import 'package:myfinance/transation.dart';
import 'package:myfinance/category.dart';

final currentPageProvider = StateProvider<String>((ref) => "Home");

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authData = ref.watch(authProvider);
    final currentPage = ref.watch(currentPageProvider);

    return Drawer(
      child: Column(
        children: [
          authData.when(
            data: (user) => UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : const NetworkImage('https://via.placeholder.com/150'),
              ),
              accountName: Text(
                user?.displayName ?? "Guest User",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                user?.email ?? "user@example.com",
                style: const TextStyle(fontSize: 14),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const ListTile(
              leading: Icon(Icons.error),
              title: Text("Error loading user"),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  text: "Home",
                  isSelected: currentPage == "Home",
                  onTap: () => _navigateTo(context, ref, "Home", HomeScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.attach_money,
                  text: "Transactions",
                  isSelected: currentPage == "Transactions",
                  onTap: () => _navigateTo(
                      context, ref, "Transactions", TransactionScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.category,
                  text: "Category",
                  isSelected: currentPage == "Category",
                  onTap: () => _navigateTo(
                      context, ref, "Category", const CategoryPage()),
                ),
              ],
            ),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            text: "Logout",
            onTap: () async {
              Navigator.pop(context); // Close drawer before sign out
              await ref.read(authServiceProvider).signOut();
              ref.read(currentPageProvider.notifier).state =
                  "Login"; // Reset page state

              // Navigate to login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
            color: Colors.red,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isSelected = false,
    Color color = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : color),
      title:
          Text(text, style: TextStyle(color: isSelected ? Colors.blue : color)),
      onTap: isSelected ? null : onTap,
    );
  }

  void _navigateTo(
      BuildContext context, WidgetRef ref, String pageName, Widget screen) {
    if (ref.read(currentPageProvider.notifier).state == pageName) return;

    ref.read(currentPageProvider.notifier).state = pageName;
    Navigator.pop(context); // Close drawer before navigating
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
