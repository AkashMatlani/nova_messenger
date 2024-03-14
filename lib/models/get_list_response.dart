class GetListDataResponse {

  String avatar;
  String description;
  String name;
  String status;
  User user;
  List<User> users;
  String uuid;

  GetListDataResponse(
      {this.avatar,
        this.description,
        this.name,
        this.status,
        this.user,
        this.users,
        this.uuid});

  GetListDataResponse.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    description = json['description'];
    name = json['name'];
    status = json['status'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    if (json['users'] != null) {
      users = <User>[];
      json['users'].forEach((v) {
        users.add(new User.fromJson(v));
      });
    }
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
    if (this.users != null) {
      data['users'] = this.users.map((v) => v.toJson()).toList();
    }
    data['uuid'] = this.uuid;
    return data;
  }
}

class User {
  String avatar;
  String lastSeen;
  String name;
  String uuid;

  User({this.avatar, this.lastSeen, this.name, this.uuid});

  User.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    lastSeen = json['last_seen'];
    name = json['name'];
    uuid = json['uuid'];
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