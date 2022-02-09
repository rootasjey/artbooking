import 'package:artbooking/types/illustration/illustration_links.dart';

class IllustrationVersion {
  String? id;
  String? name;
  DateTime? createdAt;
  IllustrationLinks? urls;

  IllustrationVersion({
    this.createdAt,
    this.id,
    this.name,
    this.urls,
  });

  factory IllustrationVersion.fromMap(Map<String, dynamic> data) {
    return IllustrationVersion(
      id: data['id'],
      name: data['name'],
      createdAt: data['created_at'],
      urls: IllustrationLinks.fromMap(data['links']),
    );
  }
}
