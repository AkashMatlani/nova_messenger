import 'package:nova/models/contact_data.dart';

class AdminContacts {

  List<ContactData> users;
  bool canContactAdmins = false;

  AdminContacts({this.users, this.canContactAdmins});

  AdminContacts.fromJson(Map<String, dynamic> json) {
    if (json['users'] != null) {
      users = <ContactData>[];
      json['users'].forEach((v) {
        users.add( ContactData.fromJson(v));
      });
    }
    canContactAdmins = json['can_contact_admins'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    if (this.users != null) {
      data['users'] = this.users.map((v) => v.toJson()).toList();
    }
    data['can_contact_admins'] = this.canContactAdmins;
    return data;
  }
}