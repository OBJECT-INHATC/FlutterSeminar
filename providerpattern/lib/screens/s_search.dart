import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:providerpattern/providers/p_auth.dart';
import 'package:providerpattern/service/sv_database.dart';
import 'package:providerpattern/widgets/w_sncakbar.dart';

/// 채팅방 검색 페이지
class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  final storage = FlutterSecureStorage();

  @override
  State<SearchPage> createState() => _SearchPageState();
}

/// 채팅방 검색 페이지 상태 클래스
class _SearchPageState extends State<SearchPage> {

  TextEditingController searchController = TextEditingController();
  QuerySnapshot? searchSnapshot;
  String userName = '';
  String token = '';

  bool hasUserSearched = false;
  bool isLoading = false;
  bool isJoined = false;

  @override
  void initState() {
    super.initState();

    /// 사용자 정보와 토큰 정보를 가져옴
    getCurrentUserIdandName();
    getToken();
  }

  /// 현재 사용자 정보
  getCurrentUserIdandName() async {
    userName = await Provider.of<AuthStore>(context, listen: false).name;
  }

  /// 토큰 정보
  getToken() async{
    token = await Provider.of<AuthStore>(context, listen: false).token;
  }

  /// 사용자 이름
  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  /// 사용자 아이디
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Search",
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search groups....",
                        hintStyle:
                        TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    /// 검색
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40)),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          isLoading
              ? Center( child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          )
              : groupList(),
        ],
      ),
    );
  }

  /// 검색 메서드
  initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      /// 이름을 통해 검색
      await DatabaseService()
          .searchByName(searchController.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          isLoading = false;
          hasUserSearched = true;
        });
      });
    }
    print("검색");
  }

  /// 검색 결과 리스트
  groupList() {
    /// 검색 결과가 있을 경우
    return hasUserSearched
        ? ListView.builder(
      shrinkWrap: true,
      itemCount: searchSnapshot!.docs.length,
      itemBuilder: (context, index) {
        return groupTile(
          userName,
          searchSnapshot!.docs[index]['groupId'],
          searchSnapshot!.docs[index]['groupName'],
          searchSnapshot!.docs[index]['admin'],
        );
      },
    )
    /// 검색 결과가 없을 경우
        : Container();
  }

  /// 그룹에 가입 되어 있는지 확인
  joinedOrNot(
      String userName, String groupId, String groupname, String admin) async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .isUserJoined(groupname, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  /// 그룹 타일 위젯
  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
    /// 그룹에 가입 되어 있는지 확인
    joinedOrNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title:
      Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          /// 가입 또는 탈퇴 메서드 호출
          bool success = await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
              .toggleGroupJoin(groupId, userName, groupName, token);

          setState(() {
            if (success) {
              /// 가입 성공
              isJoined = !isJoined;
              showSnackbar(context, isJoined ? Colors.green : Colors.red,
                  isJoined ? "Successfully joined the group" : "Left the group $groupName");
            } else {
              /// 인원이 가득 찼을 경우 가입 실패
              showSnackbar(context, Colors.red, "Group is full, cannot join.");
            }
          });
        },
        /// 가입이 되어 있을 경우
        child: isJoined
            ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 1),
          ),
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const Text(
            "Joined",
            style: TextStyle(color: Colors.white),
          ),
        )
        /// 가입이 되어 있지 않을 경우
            : Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const Text("Join Now",
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}