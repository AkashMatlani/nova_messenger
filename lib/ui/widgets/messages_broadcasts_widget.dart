import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/models/broadcasts.dart';
import 'package:nova/ui/widgets/broadcast_widget.dart';

class MessagesBroadcastsWidget extends StatelessWidget {

  final Broadcast messageOriginal;
  final Broadcast messageReply;
  final ValueChanged<Broadcast> onSwipedMessage;
  final String timestamp;
  final String read;
  final int index;

  const MessagesBroadcastsWidget({
    @required this.onSwipedMessage,
    @required this.messageReply,
    @required this.messageOriginal,
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
        child: BroadcastWidget(
          timestamp: timestamp,
          read: read,
          context: context,
          index: index,
          message: messageOriginal,
          messageReply: messageReply,
          isMe: messageOriginal.senderUuid == userUuid,
        ),
      ));
}
