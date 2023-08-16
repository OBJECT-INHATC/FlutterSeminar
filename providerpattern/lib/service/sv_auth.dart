import 'package:firebase_auth/firebase_auth.dart';
import 'package:providerpattern/service/sv_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Auth Service
class AuthService {

  /// Firebase Auth Instance
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final storage = FlutterSecureStorage();

  /// 로그인 메서드
  Future loginWithUserNameandPassword(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password))
          .user!;

      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// 회원 가입 메서드
  Future registerUserWithEmailandPassword(
      String fullName, String email, String password, String fcmToken) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password))
          .user!;

      print("user data saved");

      if (user != null) {
        /// Fire Store 사용자 정보 저장
        await DatabaseService(uid: user.uid).savingUserData(fullName, email, fcmToken);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// 로그 아웃 메서드
  Future signOut() async {
    try {
      await storage.deleteAll();
      await firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }

}