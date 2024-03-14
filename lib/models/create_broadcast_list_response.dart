import 'package:nova/models/contact_data.dart';

class CreateBroadcastListResponse {

  String description;
  int id;
  String name;
  ContactData user;
  String uuid;

  CreateBroadcastListResponse({this.description, this.id, this.name, this.user, this.uuid});

  CreateBroadcastListResponse.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    id = json['id'];
    name = json['name'];
    user = json['user'] != null ? new ContactData.fromJson(json['user']) : null;
    uuid = json['uuid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['id'] = this.id;
    data['name'] = this.name;
    data['user'] = this.user;
    data['uuid'] = this.uuid;
    return data;
  }
}