import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:providerpattern/firebase_options.dart';

import 'models/m_auth.dart';
import 'providers/p_auth.dart';
import '/screens/s_login.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AuthStore( AuthModel( Dio())),
          ),
        ],
        child: MaterialApp(
          title: 'Provider Example',
          theme: ThemeData(
          primarySwatch: Colors.blue,
          ), home: MyApp(),
      ),
  )
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }

}
