import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/art_movement/art_movement_links.dart';

/// Art style.
class ArtMovement {
  ArtMovement({
    this.createdAt,
    required this.id,
    this.name = '',
    this.description = '',
    this.links = const ArtMovementLinks(),
    this.updatedAt,
  });

  final String name;
  final String id;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ArtMovementLinks links;

  factory ArtMovement.empty() {
    return ArtMovement(
      id: '',
      name: '',
      description: '',
      links: ArtMovementLinks.empty(),
    );
  }

  factory ArtMovement.fromMap(Map<String, dynamic> data) {
    return ArtMovement(
      id: data['id'] ?? '',
      createdAt: Utilities.date.fromFirestore(data['created_at']),
      description: data['description'] ?? '',
      links: ArtMovementLinks.fromMap(data['links']),
      name: data['name'] ?? '',
      updatedAt: Utilities.date.fromFirestore(data['updated_at']),
    );
  }
}
