import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/art_movement/art_movement_links.dart';

/// Art style.
class ArtMovement {
  ArtMovement({
    this.name = '',
    this.description = '',
    this.createdAt,
    this.updatedAt,
    this.urls = const ArtMovementLinks(),
  });

  final String name;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ArtMovementLinks urls;

  factory ArtMovement.empty() {
    return ArtMovement(
      name: '',
      description: '',
      urls: ArtMovementLinks.empty(),
    );
  }

  factory ArtMovement.fromMap(Map<String, dynamic> data) {
    return ArtMovement(
      createdAt: Utilities.date.fromFirestore(data['created_at']),
      description: data['description'] ?? '',
      name: data['name'] ?? '',
      updatedAt: Utilities.date.fromFirestore(data['updated_at']),
      urls: ArtMovementLinks.fromMap(data['urls']),
    );
  }
}
