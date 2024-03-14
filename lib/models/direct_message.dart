import 'package:nova/models/contact_data.dart';
import 'package:nova/models/message.dart';

class DirectMessage {

  MessagePhoenix message;
  ContactData user;
  DirectMessage({this.message, this.user});

  DirectMessage.fromJson(Map<String, dynamic> json) {
    if (json['message'] != null) {
      message = json['message'] != null
          ? new MessagePhoenix.fromJson(json['message'])
          : null;
    }
    if (json['user'] != null) {
      user = json['user'] != null
          ? new ContactData.fromJson(json['user'])
          : null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.message != null) {
      data['message'] = this.message.toJson();
    }
    if (this.message != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}
