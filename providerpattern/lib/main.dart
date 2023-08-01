import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/auth_model.dart';
import 'services/auth_service.dart';
import '/screens/login_screen.dart';

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
            create: (context) => AuthStore( AuthModel( Dio())),
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
