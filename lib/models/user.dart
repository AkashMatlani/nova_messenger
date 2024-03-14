class User {

  String avatar;
  String name;
  String uuid;
  String statusContact;
  String receiverContact;
  String publicKey;

  User({this.avatar, this.name, this.uuid});

  User.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'] ?? "";
    name = json['name'] ?? "";
    uuid = json['uuid'] ?? "";
    name = json['name'] ?? "";
    uuid = json['uuid'] ?? "";
    publicKey = json['public_key'] ?? "";
    statusContact = json['contact_status'] ?? "";
    receiverContact = json['receiver_status'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['name'] = this.name;
    data['uuid'] = this.uuid;
    data['public_key'] = this.publicKey;
    data['contact_status'] = this.statusContact;
    data['receiver_status'] = this.receiverContact;
    return data;
  }
}
