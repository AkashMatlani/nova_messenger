class BroadcastChatModel {
  String content = "";
  String contentType = "";
  String file = "";
  String insertedAt = "";
  String user = "";
  String delete = "";
  List star = [];

  BroadcastChatModel(
      {this.content,
      this.contentType,
      this.file,
      this.insertedAt,
      this.user});

  BroadcastChatModel.fromJson(Map<String, dynamic> json) {
    content = json['content'] ?? "";
    contentType = json['content_type'] ?? "";
    file = json['file'] ?? "";
    insertedAt = json['inserted_at'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['content'] = this.content;
    data['content_type'] = this.contentType;
    data['file'] = this.file;
    data['inserted_at'] = this.insertedAt;
    return data;
  }
}
