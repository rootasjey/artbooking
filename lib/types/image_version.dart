import 'package:artbooking/types/urls.dart';

class ImageVersion {
  String id;
  String name;
  DateTime createdAt;
  Urls urls;

  ImageVersion({
    this.createdAt,
    this.id,
    this.name,
    this.urls,
  });

  factory ImageVersion.fromJSON(Map<String, dynamic> data) {
    return ImageVersion(
      id: data['id'],
      name: data['name'],
      createdAt: data['createdAt'],
      urls: Urls.fromJSON(data['urls']),
    );
  }
}
