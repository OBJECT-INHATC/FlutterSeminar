import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

/// 사용자 정보 상태 관리 Provider 클래스
class AuthStore extends ChangeNotifier {

  var email;
  var password;
  var name;
  var token;
  var loginMsg;

  Future<void> login() async {

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
        token = response.data['data']['Token'];

        notifyListeners();
      } else {
        print('Request failed with status: ${response.statusCode}');
        token = null;

        notifyListeners();
      }
    }catch (e) {
      print('DioException: $e');
      throw Exception('Failed to load data');
    }
  }
}