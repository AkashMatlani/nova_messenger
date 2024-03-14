class CreateContactsResponse {
  String avatar;
  String bio;
  String countryCode;
  String email;
  String inChat;
  String lastSeen;
  String location;
  String mobile;
  String name;
  bool privacy;
  String profileSeen;
  String status;
  String uuid;

  CreateContactsResponse(
      {this.avatar,
        this.bio,
        this.countryCode,
        this.email,
        this.inChat,
        this.lastSeen,
        this.location,
        this.mobile,
        this.name,
        this.privacy,
        this.profileSeen,
        this.status,
        this.uuid});

  CreateContactsResponse.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    bio = json['bio'];
    countryCode = json['country_code'];
    email = json['email'];
    inChat = json['in_chat'];
    lastSeen = json['last_seen'];
    location = json['location'];
    mobile = json['mobile'];
    name = json['name'];
    privacy = json['privacy'];
    profileSeen = json['profile_seen'];
    status = json['status'];
    uuid = json['uuid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['bio'] = this.bio;
    data['country_code'] = this.countryCode;
    data['email'] = this.email;
    data['in_chat'] = this.inChat;
    data['last_seen'] = this.lastSeen;
    data['location'] = this.location;
    data['mobile'] = this.mobile;
    data['name'] = this.name;
    data['privacy'] = this.privacy;
    data['profile_seen'] = this.profileSeen;
    data['status'] = this.status;
    data['uuid'] = this.uuid;
    return data;
  }
}