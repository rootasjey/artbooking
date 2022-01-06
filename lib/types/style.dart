import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/style_urls.dart';

/// Art style.
class Style {
  final String name;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final StyleUrls urls;

  Style({
    this.name = '',
    this.description = '',
    this.createdAt,
    this.updatedAt,
    this.urls = const StyleUrls(),
  });

  factory Style.empty() {
    return Style(
      name: '',
      description: '',
      urls: StyleUrls.empty(),
    );
  }

  factory Style.fromJSON(Map<String, dynamic> data) {
    return Style(
      createdAt: Utilities.date.fromFirestore(data['createdAt']),
      description: data['description'],
      name: data['name'],
      updatedAt: Utilities.date.fromFirestore(data['updatedAt']),
      urls: StyleUrls.fromJSON(data['urls']),
    );
  }
}
