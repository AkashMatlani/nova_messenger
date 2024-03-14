class CreateGroup {

  GroupData group;
  List<String> contacts;
  CreateGroup({this.group, this.contacts});

  CreateGroup.fromJson(Map<String, dynamic> json) {
    group = json['group'] != null ? new GroupData.fromJson(json['group']) : null;
    contacts = json['contacts'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.group != null) {
      data['group'] = this.group.toJson();
    }
    data['contacts'] = this.contacts;
    return data;
  }
}

class GroupData {

  String name;
  String description;
  GroupData({this.name, this.description});

  GroupData.fromJson(Map<String, dynamic> json) {
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