import 'package:nova/models/contact_data.dart';
import 'package:nova/models/message.dart';

class Messages {

  List<MessagePhoenix> messages = [];
  List<ContactData> users = [];

  Messages({this.messages});

  Messages.fromJson(Map<String, dynamic> json) {
    if (json['messages'] != null) {
      messages = <MessagePhoenix>[];
      json['messages'].forEach((v) {
        messages.add(MessagePhoenix.fromJson(v));
      });
    }
    if (json['users'] != null) {
      users = <ContactData>[];
      json['users'].forEach((v) {
        users.add(ContactData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.messages != null) {
      data['messages'] = this.messages.map((v) => v.toJson()).toList();
    }
    if (this.users != null) {
      data['users'] = this.users.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
