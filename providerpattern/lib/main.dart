import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_store.dart';
import '/screens/login.dart';

void main() {
  runApp(
      MaterialApp(
          title: 'Provider Example',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: ChangeNotifierProvider(
              create: (context) => AuthStore(),
              child: MyApp()
          )
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }
}
