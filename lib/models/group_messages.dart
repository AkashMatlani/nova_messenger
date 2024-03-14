import 'package:nova/models/group_chat_data.dart';
import 'package:nova/models/message.dart';

class GroupMessages {
  List<MessagePhoenix> messages = [];
  GroupChatData group;

  GroupMessages({this.messages});

  GroupMessages.fromJson(Map<String, dynamic> json) {
    if (json['group_messages'] != null) {
      messages = <MessagePhoenix>[];
      json['group_messages'].forEach((v) {
        messages.add(MessagePhoenix.fromJson(v));
      });
    }
    if (json['group'] != null) {
      group = json['group'] != null ? new GroupChatData.fromJson(json['group']) : null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.messages != null) {
      data['group_messages'] = this.messages.map((v) => v.toJson()).toList();
    }
    if (this.group != null) {
      data['group'] = this.group.toJson();
    }
    return data;
  }
}
