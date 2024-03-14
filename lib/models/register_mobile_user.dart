class RegisterUserMobile {

  String uuid;
  String mobile;

  RegisterUserMobile({this.uuid, this.mobile});

  RegisterUserMobile.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    mobile = json['mobile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['mobile'] = this.mobile;
    return data;
  }
}