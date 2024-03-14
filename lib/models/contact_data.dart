class ContactData {

  String avatar = "";
  String bio = "";
  String countryCode = "";
  String email = "";
  String inChat = "";
  String lastSeen = "";
  String location = "";
  String mobile = "";
  String name = "";
  bool privacy = false;
  String profileSeen = "";
  String status = "";
  String statusContact = "";
  String receiverContact = "";
  String uuid = "";
  String typing = "";
  String publicKey = "";
  bool muted = false;
  bool isSelected=false;

  ContactData(
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
      this.statusContact,
      this.receiverContact,
      this.uuid,
      this.typing,
      this.muted,
      this.publicKey,this.isSelected});

  ContactData.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'] ?? "";
    bio = json['bio'] ?? "";
    countryCode = json['country_code'] ?? "";
    email = json['email'] ?? "";
    inChat = json['in_chat'] ?? "";
    lastSeen = json['last_seen'] ?? "";
    location = json['location'] ?? "";
    mobile = json['mobile'] ?? "";
    name = json['name'] ?? "";
    privacy = json['privacy'] ?? false;
    profileSeen = json['profile_seen'] ?? "";
    status = json['status'] ?? "";
    statusContact = json['contact_status'] ?? "";
    receiverContact = json['receiver_status'] ?? "";
    uuid = json['uuid'] ?? "";
    typing = json['typing'] ?? "";
    publicKey = json['public_key'] ?? "";
    muted = json['muted'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    data['contact_status'] = this.statusContact;
    data['receiver_status'] = this.receiverContact;
    data['uuid'] = this.uuid;
    data['typing'] = this.typing;
    data['muted'] = this.muted;
    data['public_key'] = this.publicKey;
    return data;
  }

  static Map<String, dynamic> toMap(ContactData contacts) => {
        'avatar': contacts.avatar,
        'bio': contacts.bio,
        'country_code': contacts.countryCode,
        'email': contacts.email,
        'in_chat': contacts.inChat,
        'last_seen': contacts.lastSeen,
        'location': contacts.location,
        'mobile': contacts.mobile,
        'name': contacts.name,
        'privacy': contacts.privacy,
        'profile_seen': contacts.profileSeen,
        'status': contacts.status,
        'contact_status': contacts.statusContact,
        'receiver_status': contacts.receiverContact,
        'uuid': contacts.uuid,
        'typing': contacts.typing,
        'muted': contacts.muted,
        'public_key': contacts.publicKey
      };
}
