import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myfinance/HomeScreen.dart';
import 'package:myfinance/auth/authProvides.dart';
import 'package:myfinance/auth/loginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthCheckScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthCheckScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    authState.when(
      data: (user) {
        print(
            "Auth State Changed: ${user?.email ?? 'User is null (signed out)'}");
      },
      loading: () => print("Auth State: Loading..."),
      error: (err, stack) => print("Auth State Error: $err"),
    );

    return authState.when(
      data: (user) => user != null ? HomeScreen() : SignInScreen(),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Error: $err")),
    );
  }
}
