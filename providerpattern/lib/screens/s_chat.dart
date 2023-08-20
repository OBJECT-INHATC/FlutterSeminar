import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:providerpattern/database/d_chat_dao.dart';
import 'package:providerpattern/models/m_chat.dart';
import 'package:providerpattern/providers/p_auth.dart';
import 'package:providerpattern/service/sv_database.dart';
import 'package:providerpattern/widgets/w_messagetile.dart';


/// 채팅 화면
class ChatPage extends StatefulWidget {

  final String groupId;
  final String groupName;
  final String userName;

  /// 생성자
  const ChatPage(
      {Key? key,
        required this.groupId,
        required this.groupName,
        required this.userName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

/// 채팅 화면 상태 관리 클래스
class _ChatPageState extends State<ChatPage> {

  /// 채팅 메시지 스트림
  Stream<QuerySnapshot>? chats;

  /// 로컬 채팅 메시지 스트림
  List<ChatMessage>? localChats;

  /// 메시지 입력 컨트롤러
  TextEditingController messageController = TextEditingController();

  /// 스크롤 컨트롤러
  late ScrollController _scrollController;

  /// 로컬 저장소 SS
  final storage = const FlutterSecureStorage();

  /// 관리자 이름, 토큰, 사용자 Auth 정보
  String admin = "";
  String token = "";
  User? user;

  @override
  void initState() {

    getChatandAdmin(); /// 로컬 채팅 메시지, 채팅 메시지 스트림, 관리자 이름 호출
    getCurrentUserandToken(); /// 토큰, 사용자 Auth 정보 호출

    _scrollController = ScrollController(); /// 스크롤 컨트롤러 초기화
    super.initState();

  }

  /// 로컬 채팅 메시지 , 채팅 메시지 스트림, 관리자 이름 호출 메서드
  getChatandAdmin() async{

    var loalChat = await ChatDao().getChatbyGroupIdSortedByTime(widget.groupId).then((val) {
      setState(() {
        localChats = val;
      });
    });

    if (loalChat != null && loalChat.isNotEmpty) {
      final lastLocalChat = loalChat[loalChat.length - 1];

      DatabaseService().getChatsAfterSpecTime(widget.groupId, lastLocalChat.time).then((val) {
        setState(() {
          chats = val;
        });
      });
    } else {
      DatabaseService().getChats(widget.groupId).then((val) {
        setState(() {
          chats = val;
        });
      });
    }

    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }


  /// 토큰, 사용자 Auth 정보 호출 메서드
  getCurrentUserandToken() async {
    user = FirebaseAuth.instance.currentUser;
    token = await Provider.of<AuthStore>(context, listen: false).token;
  }

  @override
  Widget build(BuildContext context){

    /// 스크롤 컨트롤러 생성 + 하단 이동
    if(_scrollController.hasClients) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_sharp),
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("leave group"),
                    content: const Text("Are you sure you want to leave this group?"),
                    actions: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                      ),
                      IconButton(
                        /// 그룹 탈퇴
                        onPressed: () async {
                          await DatabaseService(uid: user!.uid).leaveGroup(
                              widget.groupId,widget.userName, widget.groupName, token);

                          ChatDao().deleteByGroupId(widget.groupId);

                          if(!mounted) return;
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.done,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[

          /// 채팅 메시지 스트림
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[700],
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                      controller: messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Send a message...",
                        hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                        border: InputBorder.none,
                      ),
                    )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        )),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  /// 채팅 메시지 스트림
  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return const Text("Something went wrong");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasData) {
          List<ChatMessage> fireStoreChats = snapshot.data!.docs
              .map<ChatMessage>((e) => ChatMessage.fromMap(e.data() as Map<String, dynamic>))
              .toList();

          /// 로컬 디비에 없는 메시지만 저장
          if (fireStoreChats.isNotEmpty) {
            for (var newChatMessage in fireStoreChats) {
              ChatDao().insert(newChatMessage);
            }
          }

          print(fireStoreChats.length);

          if(localChats != null) {
            fireStoreChats.addAll(localChats!);
          }
          print(fireStoreChats.length);

          fireStoreChats.sort((a, b) => a.time.compareTo(b.time));

          return ListView.builder(
            padding: EdgeInsets.only(bottom: 100),
            controller: _scrollController,
            itemCount: fireStoreChats.length,
            itemBuilder: (context, index) {
              return MessageTile(
                message: fireStoreChats[index].message,
                sender: fireStoreChats[index].sender,
                sentByMe: widget.userName == fireStoreChats[index].sender,
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
  }


  /// 메시지 전송 메서드 - 메시지 전달 및 로컬 저장소 메시지 저장
  sendMessage() {
    if (messageController.text.isNotEmpty) {
      /// 전달할 메시지 Map 생성
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      /// 메시지 전송
      DatabaseService().sendMessage(widget.groupId, chatMessageMap, widget.groupName, token);

      /// 스크롤 화면 하단으로 이동
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      setState(() {
        /// 메시지 입력 컨트롤러 초기화
        messageController.clear();
      });
    }
  }
}