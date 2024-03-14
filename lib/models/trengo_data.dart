class TrengoData {

  Contact contact;
  Body body;
  Attachment attachments;
  String channel;

  TrengoData({this.contact, this.body, this.attachments, this.channel});

  TrengoData.fromJson(Map<String, dynamic> json) {
    contact =
        json['contact'] != null ? new Contact.fromJson(json['contact']) : null;
    body = json['body'] != null ? new Body.fromJson(json['body']) : null;
    if (json['attachments'] != null) {
      attachments = new Attachment.fromJson(json['attachments']);
    }
    channel = json['channel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.contact != null) {
      data['contact'] = this.contact.toJson();
    }
    if (this.body != null) {
      data['body'] = this.body.toJson();
    }
    if (this.attachments != null) {
      data['attachments'] = this.attachments.toJson();
    }
    data['channel'] = this.channel;
    return data;
  }
}

class Contact {

  String name;
  String uuid;
  String identifier;

  Contact({this.name, this.uuid, this.identifier});

  Contact.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? "";
    uuid = json['uuid'] ?? "";
    identifier = json['identifier'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['uuid'] = this.uuid;
    data['identifier'] = this.identifier;
    return data;
  }
}

class Body {
  String text;

  Body({this.text});

  Body.fromJson(Map<String, dynamic> json) {
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    return data;
  }
}

class Attachment {

  String url;
  Attachment({this.url});
  Attachment.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    return data;
  }
}
