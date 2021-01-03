import 'package:artbooking/types/illustration/urls.dart';

class IllustrationVersion {
  String id;
  String name;
  DateTime createdAt;
  Urls urls;

  IllustrationVersion({
    this.createdAt,
    this.id,
    this.name,
    this.urls,
  });

  factory IllustrationVersion.fromJSON(Map<String, dynamic> data) {
    return IllustrationVersion(
      id: data['id'],
      name: data['name'],
      createdAt: data['createdAt'],
      urls: Urls.fromJSON(data['urls']),
    );
  }
}
