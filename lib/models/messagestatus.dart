class MessagesStatusResponse {
  Message message;
  Sender sender;

  MessagesStatusResponse({this.message, this.sender});

  MessagesStatusResponse.fromJson(Map<String, dynamic> json) {
    message =
        json['message'] != null ? new Message.fromJson(json['message']) : null;
    sender =
        json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.message != null) {
      data['message'] = this.message.toJson();
    }
    if (this.sender != null) {
      data['sender'] = this.sender.toJson();
    }
    return data;
  }
}

class Message {
  String content;
  String contentType;
  String file;
  String fromUuid;
  String insertedAt;
  String status;
  String toUuid;
  String uuid;
  String clientUuid;

  Message(
      {this.content,
      this.contentType,
      this.file,
      this.fromUuid,
      this.insertedAt,
      this.status,
      this.toUuid,
      this.uuid,
      this.clientUuid});

  Message.fromJson(Map<String, dynamic> json) {
    content = json['content'] ?? "";
    contentType = json['content_type'] ?? "";
    file = json['file'] ?? "";
    fromUuid = json['from_uuid'] ?? "";
    insertedAt = json['inserted_at'] ?? "";
    status = json['status'] ?? "";
    toUuid = json['to_uuid'] ?? "";
    uuid = json['uuid'] ?? "";
    clientUuid = json['client_uuid'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['content'] = this.content;
    data['content_type'] = this.contentType;
    data['file'] = this.file;
    data['from_uuid'] = this.fromUuid;
    data['inserted_at'] = this.insertedAt;
    data['status'] = this.status;
    data['to_uuid'] = this.toUuid;
    data['uuid'] = this.uuid;
    data['client_uuid'] = this.clientUuid;
    return data;
  }
}

class Sender {
  String avatar;
  String name;
  String uuid;

  Sender({this.avatar, this.name, this.uuid});

  Sender.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    name = json['name'];
    uuid = json['uuid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['name'] = this.name;
    data['uuid'] = this.uuid;
    return data;
  }
}
