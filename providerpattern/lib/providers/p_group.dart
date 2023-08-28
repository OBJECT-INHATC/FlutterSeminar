import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/models/m_auth.dart';

/// 그룹 정보 상태 관리 Provider 클래스
class GroupStore extends ChangeNotifier{

  /// 그룹 정보
  Stream? groups;

  /// 그룹 이름
  String groupName = '';

  /// 그룹 업데이트
  void setGroups(Stream? newGroups) {
    groups = newGroups;
    notifyListeners();
  }

}