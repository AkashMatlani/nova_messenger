import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/models/message.dart';
import 'message_widget.dart';

class MessagesWidget extends StatelessWidget {
  final MessagePhoenix messageOriginal;
  final MessagePhoenix messageReply;
  final bool isGroup;
  final ValueChanged<MessagePhoenix> onSwipedMessage;
  final String timestamp;
  final String read;
  final int index;

  const MessagesWidget({
    @required this.onSwipedMessage,
    @required this.messageOriginal,
    @required this.isGroup,
    @required this.messageReply,
    @required this.timestamp,
    @required this.read,
    @required this.index,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
      onHorizontalDragEnd: (_) {
        print("end");
      },
      child: Dismissible(
          key: const Key('reply_swipe'),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              onSwipedMessage(messageOriginal);
              return false;
            } else if (direction == DismissDirection.endToStart) {
              return false;
            }
            return false;
          },
          direction: DismissDirection.startToEnd,
          child: MessageWidget(
            timestamp: timestamp,
            read: read,
            message: messageOriginal,
            messageReply: messageReply,
            context: context,
            index: index,
            isGroup: isGroup,
            isMe: isGroup == false
                ? messageOriginal.fromUuid == userUuid
                : messageOriginal.user.uuid == userUuid,
          )));
}
