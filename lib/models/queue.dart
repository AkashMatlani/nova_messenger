class QueueMessage {

  String type, uuid, message, peerPublicKey;
  QueueMessage({this.type, this.uuid, this.message, this.peerPublicKey});

  QueueMessage.fromJson(Map<String, dynamic> json) {
    type = json['type'] ?? "";
    uuid = json['uuid'] ?? "";
    message = json['message'] ?? "";
    peerPublicKey = json['peer_key'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['type'] = this.type;
    data['uuid'] = this.uuid;
    data['message'] = this.message;
    data['peer_key'] = this.peerPublicKey;
    return data;
  }

  static Map<String, dynamic> toMap(QueueMessage queued) => {
    'type': queued.type,
    'uuid': queued.uuid,
    'message': queued.message,
    'peer_key': queued.peerPublicKey,
  };
}
