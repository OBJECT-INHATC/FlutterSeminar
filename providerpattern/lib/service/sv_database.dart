import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:providerpattern/models/m_chat.dart';
import 'package:providerpattern/service/sv_fcm.dart';

/// DatabaseService class - Firebase Firestore Database 관련 함수들을 모아놓은 클래스
class DatabaseService {

  /// uid - 현재 사용자의 uid
  final String? uid;

  /// 생성자
  DatabaseService({this.uid});

  /// CollectionReference - User Collection
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection("users");

  /// CollectionReference - Group Collection
  final CollectionReference groupCollection =
  FirebaseFirestore.instance.collection("groups");

  /// 현재 사용자의 User 정보를 가져오는 함수
  final User? user = FirebaseAuth.instance.currentUser;

  /// 유저 정보 Firebase 저장
  Future savingUserData(String fullName, String email, String fcmToken) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
      "fcmToken": fcmToken,
    });
  }

  /// 유저 정보 가져오는 메서드
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
    await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  /// 사용자 그룹 정보 가져오는 메서드
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  /// 그룹 정보 Firebase 저장
  Future createGroup(String userName, String id, String groupName, String token) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "maxMembers" : 3,
      "nowMembers" : 1,
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    /// 그룹 생성 후 그룹 멤버 추가
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName-$token"]),
      "groupId": groupDocumentReference.id,
    });

    /// 그룹 생성 후 사용자 정보에 그룹 정보 추가
    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
      FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  /// 입장 후 채팅 메시지 스트림 획득 메서드
  getChatsAfterJoin(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .startAfter([DateTime.now().millisecondsSinceEpoch])
        .snapshots();
  }

  getChatsAfterSpecTime(String groupId, int time) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .startAfter([time])
        .snapshots();
  }

  /// 채팅 메시지 스트림 메서드
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  /// 그룹의 어드민 정보 획득 메서드
  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  /// 그룹의 멤버 획득 메서드
  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  /// 그룹 검색 메서드
  searchByName(String groupName) {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  /// 사용자가 그룹에 가입 되어 있는지 확인하는 메서드
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  /// 그룹 가입/탈퇴 메서드 - Transaction 사용
  Future<bool> toggleGroupJoin(String groupId, String userName, String groupName, String token) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot groupSnapshot = await groupDocumentReference.get();
    int currentMembers = groupSnapshot['nowMembers'];
    int maxMembers = groupSnapshot['maxMembers'];


    if (currentMembers < maxMembers) {
      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot userSnapshot = await transaction.get(userDocumentReference);
          List<dynamic> groups = userSnapshot['groups'];

          if (groups.contains("${groupId}_$groupName")) {
            transaction.update(userDocumentReference, {
              "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
            });
            transaction.update(groupDocumentReference, {
              "members": FieldValue.arrayRemove(["${uid}_$userName-$token"]),
              "nowMembers": FieldValue.increment(-1)
            });
          } else {
            transaction.update(userDocumentReference, {
              "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
            });
            transaction.update(groupDocumentReference, {
              "members": FieldValue.arrayUnion(["${uid}_$userName-$token"]),
              "nowMembers": FieldValue.increment(1)
            });
          }
        });

        return true; // Successful action
      } catch (e) {
        print('Transaction failed: $e');
        return false; // Failed action
      }
    } else {
      print('Group is full, cannot join.');
      return false; // Group is full
    }
  }

  /// 메시지 전송 + FCM 알림 전송 메서드
  sendMessage(String groupId, Map<String, dynamic> chatMessageData, String groupName, String myToken) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });

    DocumentSnapshot groupSnapshot = await groupCollection.doc(groupId).get();
    List<dynamic> members = groupSnapshot['members'];
    List tokenList = [];
    String token = '';

    for (var member in members) {
      token = member.substring(member.indexOf('-') + 1);
      if (token != myToken) {
        tokenList.add(token);
      }
      token = '';
    }

    for(var token in tokenList) {
      print(token);
    }

    FcmService().sendMessage(
        tokenList: tokenList,
        title: "New Message in $groupName",
        body: "${chatMessageData['sender']} : ${chatMessageData['message']}",
        chatMessage: ChatMessage(
          groupId: groupId,
          message: chatMessageData['message'],
          sender: chatMessageData['sender'],
          time: chatMessageData['time'],
        )
    );

  }

  /// 그룹 탈퇴 메서드
  Future leaveGroup(String groupId, String userName, String groupName, String token) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot userSnapshot = await userDocumentReference.get();
    List<dynamic> groups = userSnapshot['groups'];

    if (groups.contains("${groupId}_$groupName")) {
      // Check if the user is the admin
      DocumentSnapshot groupSnapshot = await groupDocumentReference.get();
      String admin = groupSnapshot['admin'];

      if (admin == "${uid}_$userName") {
        // Delete the group if the user is the admin
        await groupDocumentReference.delete();
        await userDocumentReference.update({
          "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
        });
      } else {
        // User is not the admin, remove from the group
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.update(userDocumentReference, {
            "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
          });
          transaction.update(groupDocumentReference, {
            "members": FieldValue.arrayRemove(["${uid}_$userName-$token"]),
            "nowMembers": FieldValue.increment(-1)
          });
        });
      }
    } else {
      print("User is not a member of the group");
    }
  }


}