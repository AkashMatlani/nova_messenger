import 'package:nova/models/contact_data.dart';

class BroadcastList {
  String avatar = "";
  String description = "";
  String name = "";
  String status = "";
  ContactData user = ContactData();
  String uuid = "";
  ContactData contactAdmin = ContactData();
  bool muted = false;
  bool isSelected=false;

  BroadcastList(
      {this.avatar,
      this.description,
      this.name,
      this.status,
      this.user,
      this.uuid,
      this.contactAdmin,
      this.muted,this.isSelected});

  BroadcastList.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'] ?? "";
    description = json['description'] ?? "";
    name = json['name'] ?? "";
    status = json['status'] ?? "";
    user = json['user'] != null ? ContactData.fromJson(json['user']) : null;
    uuid = json['uuid'] ?? "";
    contactAdmin = json['user_admin'] != null
        ? ContactData.fromJson(json['user_admin'])
        : null;
    muted = json['muted'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['description'] = this.description;
    data['name'] = this.name;
    data['status'] = this.status;
    data['muted'] = this.muted;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    if (this.contactAdmin != null) {
      data['user_admin'] = this.contactAdmin.toJson();
    }
    data['uuid'] = this.uuid;
    return data;
  }
}
