import 'package:nova/models/broadcast_list.dart';
import 'package:nova/models/broadcasts.dart';

class BroadCastMessage {
  Broadcast message;
  BroadcastList listData;

  BroadCastMessage({this.message, this.listData});

  BroadCastMessage.fromJson(Map<String, dynamic> json) {
    if (json['broadcast'] != null) {
      message = json['broadcast'] != null
          ? new Broadcast.fromJson(json['broadcast'])
          : null;
    }
    if (json['list'] != null) {
      listData = json['list'] != null
          ? new BroadcastList.fromJson(json['list'])
          : null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.message != null) {
      data['broadcast'] = this.message.toJson();
    }
    if (this.listData != null) {
      data['list'] = this.listData.toJson();
    }
    return data;
  }
}
