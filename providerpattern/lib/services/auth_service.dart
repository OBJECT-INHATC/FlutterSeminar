import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/models/auth_model.dart';


/// 사용자 정보 상태 관리 Provider 클래스
class AuthStore extends ChangeNotifier {

  /// 사용자 정보
  var email;
  var password;
  var name;
  var token;
  var loginMsg;

  /// 생성자 의존성 주입
  final AuthModel _authModel;
  AuthStore(this._authModel);

  /// 로그인
  Future<void> login() async {
    final storage = FlutterSecureStorage();

    try {
      token = await _authModel.login(email, password);

      if (token != null) {
        print('토큰과 함께 요청 성공: $token');

        storage.deleteAll(); // 기존 토큰 삭제
        storage.write(key: 'token', value: token);
        notifyListeners();

      } else {
        print('로그인 실패');
        token = null;
        storage.deleteAll(); // 기존 토큰 삭제
        notifyListeners();

      }
    } catch (e) {
      print('예외 발생: $e');
      throw Exception('데이터 로드에 실패했습니다');
    }
  }



}