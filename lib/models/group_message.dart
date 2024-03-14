import 'package:nova/models/contact_data.dart';
import 'package:nova/models/group_chat_data.dart';

class GroupMessage {
  GroupMessageData message;
  GroupChatData group;

  GroupMessage({this.message});

  GroupMessage.fromJson(Map<String, dynamic> json) {
    if (json['group_message'] != null) {
      message = json['group_message'] != null
          ? GroupMessageData.fromJson(json['group_message'])
          : null;
    }
    if (json['group'] != null) {
      group =
          json['group'] != null ? GroupChatData.fromJson(json['group']) : null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.group != null) {
      data['group_message'] = this.message.toJson();
    }
    if (this.group != null) {
      data['group'] = this.group.toJson();
    }
    return data;
  }
}

class GroupMessageData {
  String content = "";
  String contentType = "";
  String file = "";
  String fromUuid = "";
  String toUuid = "";
  bool read = false;
  String status = "";
  bool received = false;
  String insertedAt = "";
  ContactData user;
  String delete = "";
  String clientUuid;
  String lastSeen = "";
  String uuid = "";
  List star = [];
  bool hasReplied = false;
  String repliedMessageUuid = "";
  int replyIndex = 0;
  bool hasForwarded = false;

  GroupMessageData(
      {this.content,
      this.contentType,
      this.file,
      this.fromUuid,
      this.toUuid,
      this.status,
      this.lastSeen,
      this.uuid,
      this.read,
      this.received,
      this.clientUuid,
      this.insertedAt,
      this.user,
      this.hasReplied,
      this.repliedMessageUuid,
      this.replyIndex,
      this.hasForwarded});

  GroupMessageData.fromJson(Map<String, dynamic> json) {
    content = json['content'] ?? "";
    contentType = json['content_type'] ?? "";
    file = json['file'] ?? "";
    lastSeen = json['last_seen'] ?? "";
    uuid = json['uuid'] ?? "";
    status = json['status'] ?? "";
    fromUuid = json['from_uuid'] ?? "";
    toUuid = json['to_uuid'] ?? "";
    clientUuid = json['client_uuid'] ?? "";
    user = json['user'] != null ? ContactData.fromJson(json['user']) : null;
    read = json['read'] ?? false;
    received = json['received'] ?? false;
    insertedAt = json['inserted_at'] ?? "";
    hasReplied = json['is_a_reply'] ?? false;
    repliedMessageUuid = json['replied_message_uuid'] ?? "";
    replyIndex = json['reply_index'] ?? 0;
    hasForwarded = json['is_forwarding'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['content'] = this.content;
    data['content_type'] = this.contentType;
    data['file'] = this.file;
    data['uuid'] = this.uuid;
    data['last_seen'] = this.lastSeen;
    data['status'] = this.status;
    data['from_uuid'] = this.fromUuid;
    data['to_uuid'] = this.toUuid;
    data['client_uuid'] = this.clientUuid;
    data['read'] = this.read;
    data['inserted_at'] = this.insertedAt;
    data['is_a_reply'] = this.hasReplied;
    data['replied_message_uuid'] = this.repliedMessageUuid;
    data['reply_index'] = this.replyIndex;
    data['is_forwarding'] = this.hasForwarded;
    return data;
  }
}
