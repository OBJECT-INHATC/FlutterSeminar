import 'package:dio/dio.dart';

/// API 통신을 위한 모델 클래스
class AuthModel {

  /// 생성자 의존성 주입
  final Dio _dio;
  AuthModel(this._dio);

  /// 로그인 요청
  Future<String?> login(String email, String password) async {
    try {
      var headers = {'Content-Type': 'application/json; charset=utf-8'};
      var requestBody = {
        'email': email,
        'password': password,
      };

      var response = await _dio.post(
        'http://restapi.adequateshop.com/api/authaccount/login',
        options: Options(headers: headers),
        data: requestBody,
      );

      if (response.statusCode == 200 && response.data['message'] == 'success') {
        return response.data['data']['Token'];
      }
    } catch (e) {
      print('DioException: $e');
      throw Exception('데이터 로드에 실패했습니다');
    }
    return null;
  }

}
