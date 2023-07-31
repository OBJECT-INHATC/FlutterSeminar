import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 사용자 정보 상태 관리 Provider 클래스
class AuthStore extends ChangeNotifier {

  var email;
  var password;
  var name;
  var token;
  var loginMsg;

  Future<void> login() async {

    final storage = FlutterSecureStorage();

    var dio = Dio();
    var headers = {'Content-Type': 'application/json; charset=utf-8'};
    var requestBody = {
      'email': email,
      'password': password,
    };
    try {
      var response = await dio.post('http://restapi.adequateshop.com/api/authaccount/login',
          options: Options(headers: headers),
          data: requestBody);

      loginMsg = response.data['message'].toString();

      if (response.statusCode == 200 && loginMsg == 'success') {
        print('Request succeeded with status: ${response.statusCode}');

        storage.deleteAll(); // 기존 토큰 삭제
        storage.write(key: 'token', value: response.data['data']['Token']);
        token = response.data['data']['Token'];

        notifyListeners();
      } else {
        print('Request failed with status: ${response.statusCode}');

        token = null;
        storage.deleteAll(); // 기존 토큰 삭제

        notifyListeners();
      }
    }catch (e) {
      print('DioException: $e');
      throw Exception('Failed to load data');
    }
  }
}