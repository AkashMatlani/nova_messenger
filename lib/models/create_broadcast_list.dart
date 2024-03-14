class CreateBroadcastList {

  BroadcastListCreate broadcastList;
  List<String> contacts;

  CreateBroadcastList({this.broadcastList, this.contacts});

  CreateBroadcastList.fromJson(Map<String, dynamic> json) {
    broadcastList = json['list'] != null
        ? new BroadcastListCreate.fromJson(json['list'])
        : null;
    contacts = json['contacts'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.broadcastList != null) {
      data['list'] = this.broadcastList.toJson();
    }
    data['contacts'] = this.contacts;
    return data;
  }
}

class BroadcastListCreate {

  String name = "";
  String description = "";

  BroadcastListCreate({this.name, this.description});

  BroadcastListCreate.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['description'] = this.description;
    return data;
  }
}