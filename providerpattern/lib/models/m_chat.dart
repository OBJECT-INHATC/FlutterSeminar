class ChatMessage {

  int? id;
  String? groupId;

  final String message;
  final String sender;
  final int time;

  ChatMessage( {
    required this.message,
    required this.sender,
    required this.time,
  });

  ChatMessage.withId({
    this.groupId,
    required this.message,
    required this.sender,
    required this.time,
  });

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      message: map['message'] as String,
      sender: map['sender'] as String,
      time: map['time'] as int,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
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
