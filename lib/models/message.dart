import 'package:nova/models/broadcast_list.dart';
import 'package:nova/models/contact_data.dart';
import 'package:nova/models/group_chat_data.dart';

class MessagePhoenix {

  String content = "";
  String contentType = "";
  String file = "";
  String fromUuid = "";
  String toUuid = "";
  String avatar = "";
  String status = "";
  String insertedAt = "";
  ContactData user = ContactData();
  GroupChatData group = GroupChatData();
  BroadcastList listData = BroadcastList();
  String delete = "";
  String lastSeen = "";
  String uuid = "";
  String clientUuid = "";
  bool muted = false;
  List star = [];
  String savedImage = "";
  bool hasReplied = false;
  String repliedMessageUuid = "";
  int replyIndex = 0;
  bool hasForwarded = false;
  bool isHighlighted = false;

  MessagePhoenix(
      {this.content,
      this.contentType,
      this.file,
      this.fromUuid,
      this.toUuid,
      this.status,
      this.avatar,
      this.lastSeen,
      this.uuid,
      this.insertedAt,
      this.group,
      this.listData,
      this.clientUuid,
      this.muted,
      this.user,
      this.savedImage,
      this.hasReplied,
      this.repliedMessageUuid,
      this.replyIndex,
      this.hasForwarded,
      this.isHighlighted});

  MessagePhoenix.fromJson(Map<String, dynamic> json) {
    content = json['content'] ?? "";
    contentType = json['content_type'] ?? "";
    file = json['file'] ?? "";
    lastSeen = json['last_seen'] ?? "";
    uuid = json['uuid'] ?? "";
    avatar = json['avatar'] ?? "";
    status = json['status'] ?? "";
    fromUuid = json['from_uuid'] ?? "";
    toUuid = json['to_uuid'] ?? "";
    clientUuid = json['client_uuid'] ?? "";
    muted = json['muted'] ?? false;
    user = json['user'] != null ? ContactData.fromJson(json['user']) : null;
    group =
        json['group'] != null ? GroupChatData.fromJson(json['group']) : null;
    listData =
        json['list'] != null ? BroadcastList.fromJson(json['list']) : null;
    insertedAt = json['inserted_at'] ?? "";
    savedImage = json['thumbnail'] ?? "";
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
    data['avatar'] = this.avatar;
    data['from_uuid'] = this.fromUuid;
    data['to_uuid'] = this.toUuid;
    data['user'] = this.user;
    data['group'] = this.group;
    data['list'] = this.listData;
    data['client_uuid'] = this.clientUuid;
    data['muted'] = this.muted;
    data['inserted_at'] = this.insertedAt;
    data['thumbnail'] = this.savedImage;
    data['is_a_reply'] = this.hasReplied;
    data['replied_message_uuid'] = this.repliedMessageUuid;
    data['reply_index'] = this.replyIndex;
    data['is_forwarding'] = this.hasForwarded;
    return data;
  }

  static Map<String, dynamic> toMap(MessagePhoenix chats) => {
        'content': chats.content,
        'content_type': chats.contentType,
        'file': chats.file,
        'uuid': chats.uuid,
        'last_seen': chats.lastSeen,
        'status': chats.status,
        'avatar': chats.avatar,
        'from_uuid': chats.fromUuid,
        'to_uuid': chats.toUuid,
        'user': chats.user,
        'group': chats.group,
        'list': chats.listData,
        'client_uuid': chats.clientUuid,
        'muted': chats.muted,
        'inserted_at': chats.insertedAt,
        'thumbnail': chats.savedImage,
        'is_a_reply': chats.hasReplied,
        'replied_message_uuid': chats.repliedMessageUuid,
        'reply_index': chats.replyIndex,
        'is_forwarding': chats.hasForwarded
      };
}
