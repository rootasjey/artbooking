import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/art_style/art_style_urls.dart';

/// Art style.
class ArtStyle {
  ArtStyle({
    this.name = '',
    this.description = '',
    this.createdAt,
    this.updatedAt,
    this.urls = const ArtStyleUrls(),
  });

  final String name;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ArtStyleUrls urls;

  factory ArtStyle.empty() {
    return ArtStyle(
      name: '',
      description: '',
      urls: ArtStyleUrls.empty(),
    );
  }

  factory ArtStyle.fromJSON(Map<String, dynamic> data) {
    return ArtStyle(
      createdAt: Utilities.date.fromFirestore(data['createdAt']),
      description: data['description'] ?? '',
      name: data['name'] ?? '',
      updatedAt: Utilities.date.fromFirestore(data['updatedAt']),
      urls: ArtStyleUrls.fromJSON(data['urls']),
    );
  }
}
