class ThumbnailResponse {

  String thumbnail;
  String uuid;

  ThumbnailResponse({this.thumbnail, this.uuid});

  ThumbnailResponse.fromJson(Map<String, dynamic> json) {
    thumbnail = json['thumbnail'];
    uuid = json['uuid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['thumbnail'] = this.thumbnail;
    data['uuid'] = this.uuid;
    return data;
  }
}