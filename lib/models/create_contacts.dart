import 'package:nova/models/contact_detail.dart';

class CreateContacts {

  String uuid = "";
  List<ContactDetail> contacts = [];

  CreateContacts({this.uuid, this.contacts});

  CreateContacts.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    if (json['contacts'] != null) {
      contacts = <ContactDetail>[];
      json['contacts'].forEach((v) {
        contacts.add(ContactDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uuid'] = this.uuid;
    if (this.contacts != null) {
      data['contacts'] = this.contacts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
