
class PublicKeyToken {

  User user;
  PublicKeyToken({this.user});

  PublicKeyToken.fromJson(Map<String, dynamic> json) {
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

  String publicKey;
  User({this.publicKey});

  User.fromJson(Map<String, dynamic> json) {
    publicKey = json['public_key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['public_key'] = this.publicKey;
    return data;
  }
}
