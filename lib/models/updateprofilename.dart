class UpdateProfileName {

  User user;
  UpdateProfileName({this.user});

  UpdateProfileName.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}

class User {

  String name;
  bool privacy;
  User({this.name,this.privacy});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    privacy = json['privacy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['privacy'] = this.privacy;
    return data;
  }
}