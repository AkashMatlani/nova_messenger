class RegisterUserMobileResponse {
  String countryCode;
  String mobile;
  String status;
  String token;
  String uuid;

  RegisterUserMobileResponse({this.countryCode, this.mobile, this.status, this.token, this.uuid});

  RegisterUserMobileResponse.fromJson(Map<String, dynamic> json) {
    countryCode = json['country_code'];
    mobile = json['mobile'];
    status = json['status'];
    token = json['token'];
    uuid = json['uuid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['country_code'] = this.countryCode;
    data['mobile'] = this.mobile;
    data['status'] = this.status;
    data['token'] = this.token;
    data['uuid'] = this.uuid;
    return data;
  }
}
