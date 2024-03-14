
class DeviceToken {
  UserToken user;

  DeviceToken({this.user});

  DeviceToken.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new UserToken.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}

class UserToken {

  String deviceToken;

  UserToken({this.deviceToken});

  UserToken.fromJson(Map<String, dynamic> json) {
    deviceToken = json['device_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['device_token'] = this.deviceToken;
    return data;
  }
}
