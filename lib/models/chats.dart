import 'package:nova/models/contact_data.dart';
import 'package:nova/models/broadcast_list.dart';
import 'package:nova/models/group_chat_data.dart';

class Chats {

  GroupChatData group = GroupChatData();
  LastMessage lastMessage = LastMessage();
  BroadcastList list = BroadcastList();
  String type = "";
  int unreadCount = 0;
  ContactData user = ContactData();
  String uuid = "";
  bool muted = false;

  Chats(
      {this.group,
      this.lastMessage,
      this.list,
      this.type,
      this.unreadCount,
      this.user,
      this.uuid,
      this.muted});

  Chats.fromJson(Map<String, dynamic> json) {
    group = json['group'] != null
        ?  GroupChatData.fromJson(json['group'])
        : null;
    lastMessage = json['last_message'] != null
        ?  LastMessage.fromJson(json['last_message'])
        : null;
    list =
        json['list'] != null ?  BroadcastList.fromJson(json['list']) : null;
    type = json['type'] ?? "";
    uuid = json['uuid'] ?? "";
    unreadCount = json['unread_count'] ?? 0;
    muted = json['muted'] ?? false;
    user = json['user'] != null ?  ContactData.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    if (this.group != null) {
      data['group'] = this.group.toJson();
    }
    if (this.lastMessage != null) {
      data['last_message'] = this.lastMessage.toJson();
    }
    if (this.list != null) {
      data['list'] = this.list.toJson();
    }
    data['type'] = this.type;
    data['uuid'] = this.uuid;
    data['unread_count'] = this.unreadCount;
    data['muted'] = this.muted;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }

  static Map<String, dynamic> toMap(Chats chats) => {
        'user': chats.user,
        'group': chats.group,
        'list': chats.list,
        'last_message': chats.lastMessage,
        'type': chats.type,
        'uuid': chats.uuid,
        'muted': chats.muted,
        'unread_count': chats.unreadCount,
      };
}

class LastMessage {

  String content = "";
  String contentType = "";
  String file = "";
  String fromUuid = "";
  String insertedAt = "";
  String status = "";
  String toUuid = "";
  String uuid = "";
  String clientUuid = "";
  bool read = false;
  bool received = false;

  LastMessage(
      {this.content,
      this.contentType,
      this.file,
      this.fromUuid,
      this.insertedAt,
      this.status,
      this.toUuid,
      this.uuid,
      this.clientUuid,
      this.read,
      this.received});

  LastMessage.fromJson(Map<String, dynamic> json) {
    content = json['content'] ?? "";
    contentType = json['content_type'] ?? "";
    file = json['file'] ?? "";
    fromUuid = json['from_uuid'] ?? "";
    insertedAt = json['inserted_at'] ?? "";
    status = json['status'] ?? "";
    toUuid = json['to_uuid'] ?? "";
    uuid = json['uuid'] ?? "";
    clientUuid = json['client_uuid'] ?? "";
    read = json['read'] ?? false;
    received = json['received'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['content'] = this.content;
    data['content_type'] = this.contentType;
    data['file'] = this.file;
    data['from_uuid'] = this.fromUuid;
    data['inserted_at'] = this.insertedAt;
    data['status'] = this.status;
    data['to_uuid'] = this.toUuid;
    data['uuid'] = this.uuid;
    data['client_uuid'] = this.clientUuid;
    data['read'] = this.read;
    data['received'] = this.received;
    return data;
  }
}
