import 'package:artbooking/types/masterpiece_links.dart';

class IllustrationVersion {
  IllustrationVersion({
    required this.createdAt,
    required this.id,
    required this.name,
    required this.links,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final MasterpieceLinks links;

  factory IllustrationVersion.fromMap(Map<String, dynamic> data) {
    return IllustrationVersion(
      id: data["id"],
      name: data["name"],
      createdAt: data["created_at"],
      links: MasterpieceLinks.fromMap(data["links"]),
    );
  }
}
