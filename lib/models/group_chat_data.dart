import 'package:nova/models/contact_data.dart';

class GroupChatData {

  String avatar = "";
  String description = "";
  String name = "";
  String status = "";
  ContactData user = ContactData();
  bool muted = false;
  String uuid = "";
  bool isSelected = false;

  GroupChatData(
      {this.avatar,
      this.description,
      this.name,
      this.status,
      this.user,
      this.uuid,
      this.muted,
      this.isSelected});

  GroupChatData.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'] ?? "";
    description = json['description'] ?? "";
    name = json['name'] ?? "";
    status = json['status'] ?? "";
    user = json['user'] != null ? ContactData.fromJson(json['user']) : null;
    uuid = json['uuid'] ?? "";
    muted = json['muted'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['description'] = this.description;
    data['name'] = this.name;
    data['status'] = this.status;
    data['muted'] = this.muted;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    data['uuid'] = this.uuid;
    return data;
  }
}
