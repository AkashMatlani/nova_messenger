class RegisterStudentMobile {

  String mobile;
  String externalId;
  String institutionId;

  RegisterStudentMobile({this.mobile, this.externalId,this.institutionId});

  RegisterStudentMobile.fromJson(Map<String, dynamic> json) {
    mobile = json['mobile'];
    externalId = json['external_id'];
    institutionId = json['institution_uuid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['mobile'] = this.mobile;
    data['external_id'] = this.externalId;
    data['institution_uuid'] = this.institutionId;
    return data;
  }
}