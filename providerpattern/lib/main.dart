import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '/screens/main_list.dart';
import '/providers/list_store.dart';
import '/providers/auth_store.dart';
import '/screens/login.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Provider Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AuthStore(),
          ),
          ChangeNotifierProvider(
            create: (context) => ListStore(),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }

}
