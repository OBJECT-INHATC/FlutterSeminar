import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/models/m_auth.dart';



/// 사용자 정보 상태 관리 Provider 클래스
class AuthStore extends ChangeNotifier {

  /// 사용자 정보
  var email;
  var password;
  var name;
  var token;
  var loginMsg;
  var gender;

  /// 생성자 의존성 주입
  final AuthModel _authModel;

  AuthStore(this._authModel);

  /// 로그인
  Future<bool> login(String name, String email) async {

    final storage = FlutterSecureStorage();

    final fullName = await storage.read(key: 'fullName');
    final storedEmail = await storage.read(key: 'email');

    if (fullName != null && storedEmail != null) {
      // 이미 fullName과 email이 저장되어 있는 경우
      return true;
    } else {
      // 저장되어 있지 않은 경우 fullName과 email 저장 후 반환
      await storage.deleteAll();
      await storage.write(key: 'fullName', value: name);
      await storage.write(key: 'email', value: email);
      notifyListeners();

      return true; // 또는 다른 값을 반환하거나, 반환하지 않을 수 있음
    }

  }

}



