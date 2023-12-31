import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:providerpattern/providers/p_auth.dart';
import '/service/sv_auth.dart';

/// 회원 가입 페이지
class RegisterPage extends StatelessWidget{

  RegisterPage({super.key});

  // 미디어 쿼리 사용을 위한 함수
  double mediaHeight(BuildContext context, double scale) => MediaQuery.of(context).size.height * scale;
  double mediaWidth(BuildContext context, double scale) => MediaQuery.of(context).size.width * scale;

  @override
  Widget build(BuildContext context) {

    /// AuthStore Provider Container 생성
    final authStore = Provider.of<AuthStore>(context);

    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: mediaHeight(context, 0.1)),
            Container(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
              child: TextField(
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // 밑줄 색상 설정
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue), // 포커스된 상태의 밑줄 색상 설정
                  ),
                  labelText: '이름',
                ),
                onChanged: (text) {
                  authStore.name = text;
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
              child: Stack(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      labelText: '이메일',
                    ),
                    onChanged: (text) {
                      authStore.email = text;
                    },
                  ),
                  Positioned(
                    right: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                      ),
                      onPressed: () {

                      },
                      child: Text('인증번호 전송',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold
                          )),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // 밑줄 색상 설정
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue), // 포커스된 상태의 밑줄 색상 설정
                  ),
                  labelText: '비밀번호',
                ),
                onChanged: (text) {
                  authStore.password = text;
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // 밑줄 색상 설정
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue), // 포커스된 상태의 밑줄 색상 설정
                  ),
                  labelText: '비밀번호 확인',
                ),
                onChanged: (text) {

                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(15, 20, 40, 0),
              child: Column(
                children: [
                  RadioListTile(
                    title: Text("남성"),
                    value: "남성",
                    groupValue: authStore.gender,
                    onChanged: (value){
                      authStore.gender = value;
                    },
                    fillColor: MaterialStateProperty.all(Colors.blue),
                  ),

                  RadioListTile(
                    title: Text("여성"),
                    value: "여성",
                    groupValue: authStore.gender,
                    onChanged: (value){
                      authStore.gender = value;
                    },
                    fillColor: MaterialStateProperty.all(Colors.red),
                  ),
                ],
              ),
            ),

            SizedBox(height: mediaHeight(context, 0.1)),

            Container(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
              child: Stack(
                children: [
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      labelText: '인증 번호',
                    ),
                    onChanged: (text) {
                      // 텍스트 필드 값 변경 시 실행할 코드 작성
                    },
                  ),
                  Positioned(
                    right: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                      ),
                      onPressed: () {

                      },
                      child: Text('확인',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold
                          )),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 80,
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.grey[700],
                  ),
                  child: const Text(
                      '가입완료',
                      style: TextStyle(
                          fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold
                      )
                  ),
                  onPressed: () {
                    /// 회원 가입 메서드 호출
                    AuthService().registerUserWithEmailandPassword(
                        authStore.name,
                        authStore.email,
                        authStore.password,
                        authStore.token
                    ).then((value) async {
                      /// 회원 가입 성공 시 로그인 페이지로 이동
                      if (value == true) {
                        Navigator.pop(context);
                      }
                    });

                  }
              ),
            ),
          ],
        ),
      ),
    );
  }
}