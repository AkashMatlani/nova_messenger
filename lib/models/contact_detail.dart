class ContactDetail {

  String email = "";
  String name = "";
  String number = "";

  ContactDetail({this.email, this.name, this.number});

  ContactDetail.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    name = json['name'];
    number = json['number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['email'] = this.email;
    data['name'] = this.name;
    data['number'] = this.number;
    return data;
  }
}