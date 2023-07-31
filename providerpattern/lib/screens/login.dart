import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '/screens/main_list.dart';

/// 로그인 페이지
class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var token;
  final storage = FlutterSecureStorage();

  _asyncMethod() async {
    if (await storage.read(key: "token") != null) {
      if(!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => MainList()));
    }
  }

  @override
  void initState() {
    super.initState();
    _asyncMethod();
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
                      await authStore.login().then((_) {
                        if (authStore.token != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MainList()) // 로그인 이동
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authStore.loginMsg),
                            ),
                          );
                        }});
                    }),
                  ),
              TextButton(
                onPressed: () {},
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
