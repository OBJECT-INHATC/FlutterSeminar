import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/models/m_auth.dart';

class GroupStore extends ChangeNotifier{

  Stream? groups;
  String groupName = '';

}