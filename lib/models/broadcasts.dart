import 'package:nova/models/broadcast_list.dart';

class BroadCastMessages {

  List<Broadcast> broadcasts;
  BroadcastList broadcastList;

  BroadCastMessages({this.broadcasts, this.broadcastList});

  BroadCastMessages.fromJson(Map<String, dynamic> json) {
    if (json['broadcasts'] != null) {
      broadcasts =  List<Broadcast>();
      json['broadcasts'].forEach((v) {
        broadcasts.add( Broadcast.fromJson(v));
      });
    }
    broadcastList =
        json['list'] != null ?  BroadcastList.fromJson(json['list']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    if (this.broadcasts != null) {
      data['broadcasts'] = this.broadcasts.map((v) => v.toJson()).toList();
    }
    if (this.broadcastList != null) {
      data['list'] = this.broadcastList.toJson();
    }
    return data;
  }
}

class Broadcast {
  String avatar = "";
  String content = "";
  String contentType = "";
  String file = "";
  String fromUuid = "";
  String insertedAt = "";
  String ownerUuid = "";
  String status = "";
  String uuid = "";
  String star = "";
  String clientUuid = "";
  String savedImage = "";
  String listUserName = "";
  String senderUuid = "";
  String senderName = "";
  bool hasReplied = false;
  String repliedMessageUuid = "";
  int replyIndex = 0;
  bool hasForwarded = false;
  bool isHighlighted = false;

  Broadcast(
      {this.avatar,
        this.content,
      this.contentType,
      this.file,
      this.fromUuid,
      this.insertedAt,
      this.ownerUuid,
      this.status,
      this.uuid,
      this.clientUuid,
      this.savedImage,
      this.listUserName,
      this.senderUuid,
      this.senderName,
      this.hasReplied,
      this.repliedMessageUuid,
      this.replyIndex,
      this.hasForwarded});

  Broadcast.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'] ?? "";
    content = json['content'] ?? "";
    contentType = json['content_type'] ?? "";
    file = json['file'] ?? "";
    fromUuid = json['from_uuid'] ?? "";
    insertedAt = json['inserted_at'] ?? "";
    ownerUuid = json['owner_uuid'] ?? "";
    status = json['status'] ?? "";
    uuid = json['uuid'] ?? "";
    clientUuid = json['client_uuid'] ?? "";
    savedImage = json['thumbnail'] ?? "";
    listUserName = json['sender_uuid'] ?? "";
    senderUuid = json['sender_id'] ?? "";
    senderName = json['sender_name'] ?? "";
    hasReplied = json['is_a_reply'] ?? false;
    repliedMessageUuid = json['replied_message_uuid'] ?? "";
    replyIndex = json['reply_index'] ?? 0;
    hasForwarded = json['is_forwarding'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['content'] = this.content;
    data['content_type'] = this.contentType;
    data['file'] = this.file;
    data['from_uuid'] = this.fromUuid;
    data['inserted_at'] = this.insertedAt;
    data['owner_uuid'] = this.ownerUuid;
    data['status'] = this.status;
    data['uuid'] = this.uuid;
    data['client_uuid'] = this.clientUuid;
    data['thumbnail'] = this.savedImage;
    data['sender_uuid'] = this.listUserName;
    data['sender_id'] = this.senderUuid;
    data['sender_name'] = this.senderName;
    data['is_a_reply'] = this.hasReplied;
    data['replied_message_uuid'] = this.repliedMessageUuid;
    data['reply_index'] = this.replyIndex;
    data['is_forwarding'] = this.hasForwarded;
    return data;
  }
}
