import 'package:providerpattern/models/m_chat.dart';
import 'package:sembast/sembast.dart';
import 'd_database.dart';

class ChatDao {
  static const String folderName = "chat";

  final _chatFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  /// 채팅 메시지 단일 저장
  Future insert(ChatMessage chatMessage) async {
    await _chatFolder.add(await _db, chatMessage.toMap());
  }

  /// 채팅 메시지 저장
  Future saveChatMessages(List<ChatMessage> newMessages) async {
    final existingMessages = await getChatbyGroupIdSortedByTime(newMessages.first.groupId);

    for (var newMessage in newMessages) {
      if (!existingMessages.contains(newMessage)) {
        insert(newMessage);
        existingMessages.add(newMessage); // 기존 리스트에도 추가
      }
    }
  }

  /// 채팅 메시지 삭제
  Future delete(ChatMessage chatMessage) async {
    final finder = Finder(filter: Filter.byKey(chatMessage.id));
    await _chatFolder.delete(await _db, finder: finder);
  }

  /// 채팅 메시지 전체 삭제
  Future deleteAll() async {
    await _chatFolder.delete(await _db);
  }

  /// 그룹 아이디 - 채팅 메시지 삭제
  Future deleteByGroupId(String groupId) async {
    final finder = Finder(filter: Filter.equals('groupId', groupId));
    await _chatFolder.delete(await _db, finder: finder);
  }

  /// 그룹 아이디 - 채팅 메시지 리스트 반환
  Future<List<ChatMessage>> getChatbyGroupIdSortedByTime(String groupId) async {
    final finder = Finder(filter: Filter.equals('groupId', groupId), sortOrders: [SortOrder('time')]);

    final recordSnapshots = await _chatFolder.find(await _db, finder: finder);

    return recordSnapshots.map((snapshot) {
      final chatMessage = ChatMessage.fromMap(snapshot.value, groupId);
      chatMessage.id = snapshot.key;
      return chatMessage;
    }).toList();

  }

  /// 그룹 아이디 - 채팅 메시지 리스트 반환
  Future<List<ChatMessage>> getChatByGroupId(String groupId) async {
    final finder = Finder(filter: Filter.equals('groupId', groupId));

    final recordSnapshots = await _chatFolder.find(await _db, finder: finder);

    print(recordSnapshots.length);

    return recordSnapshots.map((snapshot) {
      final chatMessage = ChatMessage.fromMap(snapshot.value, groupId);
      chatMessage.id = snapshot.key;
      return chatMessage;
    }).toList();

  }

}