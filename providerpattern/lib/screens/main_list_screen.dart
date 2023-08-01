import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/screens/login_screen.dart';

/// 메인 리스트 화면
class MainList extends StatelessWidget {
  const MainList({super.key});

  @override
  Widget build(BuildContext context) {

    final storage = FlutterSecureStorage();

    return Scaffold(
      appBar: AppBar(
        title: Text('메인 리스트'),
      ),
      body: WillPopScope(
        onWillPop: () async => false, // 뒤로 가기 금지
        child: Center(
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
              Text('메인 리스트'),
              ElevatedButton(onPressed: (){
                storage.deleteAll();
                Navigator.pop( context, MaterialPageRoute(builder: (context) => LoginPage()));
                }
                , child: Text('logout'))
            ],
          ),
        ),
      ),
    );
  }
}
