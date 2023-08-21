class ChatMessage {

  @override
  int get hashCode => message.hashCode ^ sender.hashCode ^ time.hashCode ^ groupId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatMessage &&
              runtimeType == other.runtimeType &&
              message == other.message &&
              sender == other.sender &&
              time == other.time &&
              groupId == other.groupId;

  int? id;

  final String groupId;
  final String message;
  final String sender;
  final int time;

  ChatMessage( {
    required this.groupId,
    required this.message,
    required this.sender,
    required this.time,
  });

  static ChatMessage fromMap(Map<String, dynamic> map, String groupId) {
    return ChatMessage(
      groupId: groupId,
      message: map['message'] as String,
      sender: map['sender'] as String,
      time: map['time'] as int,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      groupId: json['groupId'] as String,
      message: json['message'] as String,
      sender: json['sender'] as String,
      time: json['time'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'message': message,
      'sender': sender,
      'time': time,
    };
  }

}
