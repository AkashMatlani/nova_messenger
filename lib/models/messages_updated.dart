class MessagesUpdated {

  String uuid = "";

  MessagesUpdated(
      {
        this.uuid,
   });

  MessagesUpdated.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    return data;
  }

}
