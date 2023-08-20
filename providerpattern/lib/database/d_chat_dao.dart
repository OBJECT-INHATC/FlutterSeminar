import 'package:providerpattern/models/m_chat.dart';
import 'package:sembast/sembast.dart';
import 'd_database.dart';

class ChatDao {
  static const String folderName = "chat";

  final _chatFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(ChatMessage chatMessage) async {
    await _chatFolder.add(await _db, chatMessage.toMap());
  }

  Future update(ChatMessage chatMessage) async {
    final finder = Finder(filter: Filter.byKey(chatMessage.id));
    await _chatFolder.update(await _db, chatMessage.toMap(), finder: finder);
  }

  Future delete(ChatMessage chatMessage) async {
    final finder = Finder(filter: Filter.byKey(chatMessage.id));
    await _chatFolder.delete(await _db, finder: finder);
  }

  Future deleteAll() async {
    await _chatFolder.delete(await _db);
  }

  Future deleteByGroupId(String groupId) async {
    final finder = Finder(filter: Filter.equals('groupId', groupId));
    await _chatFolder.delete(await _db, finder: finder);
  }

  Future<List<ChatMessage>> getChatbyGroupIdSortedByTime(String groupId) async {
    final finder = Finder(filter: Filter.equals('groupId', groupId), sortOrders: [SortOrder('time')]);

    final recordSnapshots = await _chatFolder.find(await _db, finder: finder);

    return recordSnapshots.map((snapshot) {
      final chatMessage = ChatMessage.fromMap(snapshot.value);
      chatMessage.id = snapshot.key;
      return chatMessage;
    }).toList();



  }

}