class UpdateBroadcastImageResponse {

  String avatar;
  String description;
  String name;
  String status;
  User user;
  String uuid;

  UpdateBroadcastImageResponse(
      {this.avatar,
        this.description,
        this.name,
        this.status,
        this.user,
        this.uuid});

  UpdateBroadcastImageResponse.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'] ?? "";
    description = json['description'] ?? "";
    name = json['name'] ?? "";
    status = json['status'] ??"";
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    uuid = json['uuid'] ?? "";
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

class User {

  String avatar;
  String name;
  String uuid;

  User({this.avatar, this.name, this.uuid});

  User.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    name = json['name'];
    uuid = json['uuid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['name'] = this.name;
    data['uuid'] = this.uuid;
    return data;
  }
}
