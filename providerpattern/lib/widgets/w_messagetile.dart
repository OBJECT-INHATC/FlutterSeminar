import 'package:flutter/material.dart';

/// 메시지 타입 ENUM
enum MessageType {
  me,
  other,
  service,
}

/// MessageTile 위젯
class MessageTile extends StatelessWidget {
  final String message;
  final String sender;
  final MessageType messageType;

  const MessageTile({
    Key? key,
    required this.message,
    required this.sender,
    required this.messageType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Alignment alignment;
    Color bubbleColor;

    /// 메시지 타입에 따라 정렬, 색상 변경
    switch (messageType) {
      case MessageType.me:
        alignment = Alignment.centerRight;
        bubbleColor = Theme.of(context).primaryColor;
        break;
      case MessageType.other:
        alignment = Alignment.centerLeft;
        bubbleColor = Colors.grey[700]!;
        break;
      case MessageType.service:
        alignment = Alignment.center;
        bubbleColor = Colors.orange; // 서비스 메시지 색상
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: bubbleColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (messageType != MessageType.service)
              Text(
                sender.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            const SizedBox(height: 7),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}


// class _MessageTileState extends State<MessageTile> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//           top: 4,
//           bottom: 4,
//           left: widget.sentByMe ? 0 : 24,
//           right: widget.sentByMe ? 24 : 0),
//       alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: widget.sentByMe
//             ? const EdgeInsets.only(left: 30)
//             : const EdgeInsets.only(right: 30),
//         padding:
//         const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
//         decoration: BoxDecoration(
//             borderRadius: widget.sentByMe
//                 ? const BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//               bottomLeft: Radius.circular(20),
//             )
//                 : const BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//               bottomRight: Radius.circular(20),
//             ),
//             color: widget.sentByMe
//                 ? Theme.of(context).primaryColor
//                 : Colors.grey[700]),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.sender.toUpperCase(),
//               textAlign: TextAlign.start,
//               style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: -0.5),
//             ),
//             const SizedBox(
//               height: 8,
//             ),
//             Text(widget.message,
//                 textAlign: TextAlign.start,
//                 style: const TextStyle(fontSize: 16, color: Colors.white))
//           ],
//         ),
//       ),
//     );
//   }
// }