import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection("users");

  final CollectionReference groupCollection =
  FirebaseFirestore.instance.collection("groups");

  final User? user = FirebaseAuth.instance.currentUser;

  // saving the userdata
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  // getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
    await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  // get user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  // creating a group
  Future createGroup(String userName, String id, String groupName) async {
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
    // update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
      FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  // getting the chats
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  // get group members
  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // search
  searchByName(String groupName) {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  // function -> bool
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


  // // toggling the group join/exit
  // Future toggleGroupJoin(
  //     String groupId, String userName, String groupName) async {
  //   // doc reference
  //   DocumentReference userDocumentReference = userCollection.doc(uid);
  //   DocumentReference groupDocumentReference = groupCollection.doc(groupId);
  //
  //   DocumentSnapshot documentSnapshot = await userDocumentReference.get();
  //   List<dynamic> groups = await documentSnapshot['groups'];
  //
  //   // if user has our groups -> then remove then or also in other part re join
  //   if (groups.contains("${groupId}_$groupName")) {
  //     await userDocumentReference.update({
  //       "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
  //     });
  //     await groupDocumentReference.update({
  //       "members": FieldValue.arrayRemove(["${uid}_$userName"])
  //     });
  //     await groupDocumentReference.update({
  //       "nowMembers": FieldValue.increment(-1)
  //     });
  //   } else {
  //     await userDocumentReference.update({
  //       "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
  //     });
  //     await groupDocumentReference.update({
  //       "members": FieldValue.arrayUnion(["${uid}_$userName"])
  //     });
  //     await groupDocumentReference.update({
  //       "nowMembers": FieldValue.increment(1)
  //     });
  //   }
  // }

  // toggling the group join/exit + transaction
  Future<bool> toggleGroupJoin(String groupId, String userName, String groupName) async {
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
              "members": FieldValue.arrayRemove(["${uid}_$userName"]),
              "nowMembers": FieldValue.increment(-1)
            });
          } else {
            transaction.update(userDocumentReference, {
              "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
            });
            transaction.update(groupDocumentReference, {
              "members": FieldValue.arrayUnion(["${uid}_$userName"]),
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

  // send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }

  // Leaving a group -> 아직 오류임 수정 필요
  Future leaveGroup(String groupId, String userName, String groupName) async {
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
            "members": FieldValue.arrayRemove(["${uid}_$userName"]),
            "nowMembers": FieldValue.increment(-1)
          });
        });
      }
    } else {
      print("User is not a member of the group");
    }
  }


}