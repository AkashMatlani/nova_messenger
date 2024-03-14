class GroupsData {
  
  String avatar;
  String description;
  String name;
  String status;
  UserGroup user;
  String uuid;

  GroupsData(
      {this.avatar,
        this.description,
        this.name,
        this.status,
        this.user,
        this.uuid});

  GroupsData.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    description = json['description'];
    name = json['name'];
    status = json['status'];
    user = json['user'] != null ? new UserGroup.fromJson(json['user']) : null;
    uuid = json['uuid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['description'] = this.description;
    data['name'] = this.name;
    data['status'] = this.status;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    data['uuid'] = this.uuid;
    return data;
  }
}

class UserGroup {

  String avatar;
  String lastSeen;
  String name;
  String uuid;

  UserGroup({this.avatar, this.lastSeen, this.name, this.uuid});

  UserGroup.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'] ?? "";
    lastSeen = json['last_seen'] ?? "";
    name = json['name'] ?? "";
    uuid = json['uuid'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['last_seen'] = this.lastSeen;
    data['name'] = this.name;
    data['uuid'] = this.uuid;
    return data;
  }
}
