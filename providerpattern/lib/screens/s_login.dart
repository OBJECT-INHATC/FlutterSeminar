import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:providerpattern/screens/s_home.dart';
import 'package:providerpattern/service/sv_auth.dart';
import 'package:providerpattern/service/sv_database.dart';
import '../providers/p_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '/screens/s_main.dart';
import '/screens/s_register.dart';

/// 로그인 페이지
class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final storage = FlutterSecureStorage();

  _asyncMethod() async {
    if (await storage.read(key: "email") != null && await storage.read(key: "fullName") != null) {
      if(!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  @override
  void initState() {
    super.initState();
    // _asyncMethod();
  }

  @override
  Widget build(BuildContext context) {

    final authStore = Provider.of<AuthStore>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('로그인'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 70),
                child: FlutterLogo(
                  size: 40,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(90.0),
                    ),
                    labelText: 'Email',
                  ),
                  onChanged: (text) {
                    authStore.email = text;
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(90.0),
                    ),
                    labelText: 'Password',
                  ),
                  onChanged: (text) {
                    authStore.password = text;
                  },
                ),
              ),
              Container(
                  height: 80,
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Log In'),
                    onPressed: () async {
                      AuthService().loginWithUserNameandPassword(
                          authStore.email,
                          authStore.password
                      ).then((value) async {
                        if(value == true){
                          QuerySnapshot snapshot =
                          await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                              .gettingUserData(authStore.email);
                          authStore.login(snapshot.docs[0]['fullName'], snapshot.docs[0]['email']);
                          await storage.write(key: "email", value: snapshot.docs[0]['email']);
                          await storage.write(key: "fullName", value: snapshot.docs[0]['fullName']);
                          if (!mounted) return;
                          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                        }
                        else{
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(value.toString())));
                        }
                      });
                    }),
                  ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterPage(),
                    ),
                  );
                },
                child: Text(
                  'have no account? sign up',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ));
  }
}
