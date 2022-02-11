import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/illustration/dimensions.dart';
import 'package:artbooking/types/illustration/illustration_links.dart';
import 'package:artbooking/types/illustration/illustration_version.dart';
import 'package:artbooking/types/license/license.dart';

class Illustration {
  const Illustration({
    this.artMovements = const [],
    required this.createdAt,
    this.description = '',
    required this.dimensions,
    this.extension = '',
    this.id = '',
    required this.license,
    this.name = '',
    this.size = 0,
    this.lore = '',
    this.topics = const [],
    required this.updatedAt,
    required this.links,
    this.userId = '',
    this.version = 0,
    this.visibility = EnumContentVisibility.private,
  });

  /// The time this illustration has been created.
  final DateTime createdAt;

  /// This illustration's description.
  final String description;

  /// This Illustration's dimensions.
  final Dimensions dimensions;

  /// File's extension.
  final String extension;

  /// Firestore id.
  final String id;

  /// Specifies how this illustration can be used.
  final License license;

  /// This illustration's name.
  final String name;

  /// Detailed text explaining more about this illustration.
  final String lore;

  /// Cloud Storage file's size in bytes.
  final int size;

  /// Art movement (e.g. pointillism, realism) — Limited to 5.
  final List<String> artMovements;

  /// Arbitrary subjects (e.g. video games, movies) — Limited to 5.
  final List<String> topics;

  /// Last time this illustration was updated.
  final DateTime updatedAt;

  /// This illustration's urls.
  final IllustrationLinks links;

  final String userId;

  /// Number of times the image has been updated & overwritten.
  /// When this value is 0, it means that the image is being upload
  /// and not available yet. The value is updated to 1 when image upload, and
  /// thumbnails generation are done.
  final int version;

  /// Access control policy.
  /// Define who can read or write this illustration.
  final EnumContentVisibility visibility;

  factory Illustration.empty() {
    return Illustration(
      artMovements: const [],
      createdAt: DateTime.now(),
      description: '',
      dimensions: Dimensions.empty(),
      extension: '',
      id: '',
      license: License.empty(),
      name: '',
      size: 0,
      lore: '',
      topics: const [],
      updatedAt: DateTime.now(),
      links: IllustrationLinks.empty(),
      userId: '',
      version: 0,
      visibility: EnumContentVisibility.private,
    );
  }

  factory Illustration.fromMap(Map<String, dynamic> data) {
    return Illustration(
      artMovements: parseArtMovements(data['art_movements']),
      createdAt: Utilities.date.fromFirestore(data['created_at']),
      description: data['description'] ?? '',
      dimensions: Dimensions.fromMap(data['dimensions']),
      extension: data['extension'] ?? '',
      id: data['id'] ?? '',
      license: License.fromMap(data['license']),
      links: IllustrationLinks.fromMap(data['links']),
      lore: data['lore'] ?? '',
      name: data['name'] ?? '',
      size: data['size'] ?? 0,
      topics: parseTopics(data['topics']),
      updatedAt: Utilities.date.fromFirestore(data['updated_at']),
      userId: data['user_id'] ?? '',
      version: data['version'] ?? 0,
      visibility: parseVisibility(data['visibility']),
    );
  }

  String getHDThumbnail() {
    final t720 = links.thumbnails.t720;
    if (t720.isNotEmpty) {
      return t720;
    }

    final t1080 = links.thumbnails.t1080;
    if (t1080.isNotEmpty) {
      return t1080;
    }

    return links.original;
  }

  String getThumbnail() {
    final t360 = links.thumbnails.t360;
    if (t360.isNotEmpty) {
      return t360;
    }

    final t480 = links.thumbnails.t480;
    if (t480.isNotEmpty) {
      return t480;
    }

    final t720 = links.thumbnails.t720;
    if (t720.isNotEmpty) {
      return t720;
    }

    final t1080 = links.thumbnails.t1080;
    if (t1080.isNotEmpty) {
      return t1080;
    }

    return links.original;
  }

  static List<String> parseArtMovements(Map<String, dynamic>? data) {
    final results = <String>[];

    if (data == null) {
      return results;
    }

    data.forEach((key, value) {
      results.add(key);
    });

    return results;
  }

  static List<String> parseTopics(data) {
    final results = <String>[];

    if (data == null) {
      return results;
    }

    data.forEach((key, value) {
      results.add(key);
    });

    return results;
  }

  static EnumContentVisibility parseVisibility(String? stringVisiblity) {
    switch (stringVisiblity) {
      case 'acl':
        return EnumContentVisibility.acl;
      case 'archived':
        return EnumContentVisibility.archived;
      case 'private':
        return EnumContentVisibility.private;
      case 'public':
        return EnumContentVisibility.public;
      default:
        return EnumContentVisibility.private;
    }
  }

  String visibilityToString() {
    return convertVisibilityToString(visibility);
  }

  static String convertVisibilityToString(EnumContentVisibility visibility) {
    switch (visibility) {
      case EnumContentVisibility.acl:
        return 'acl';
      case EnumContentVisibility.archived:
        return 'archived';
      case EnumContentVisibility.private:
        return 'private';
      case EnumContentVisibility.public:
        return 'public';
      default:
        return 'private';
    }
  }

  Illustration copyWith({
    DateTime? createdAt,
    String? description,
    Dimensions? dimensions,
    String? extension,
    String? id,
    License? license,
    String? name,
    IllustrationLinks? links,
    String? lore,
    int? size,
    List<String>? styles,
    List<String>? topics,
    DateTime? updatedAt,
    String? userId,
    int? version,
    List<IllustrationVersion>? versions,
    EnumContentVisibility? visibility,
  }) {
    return Illustration(
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      dimensions: dimensions ?? this.dimensions,
      extension: extension ?? this.extension,
      id: id ?? this.id,
      license: license ?? this.license,
      links: links ?? this.links,
      name: name ?? this.name,
      lore: lore ?? this.lore,
      size: size ?? this.size,
      artMovements: styles ?? this.artMovements,
      topics: topics ?? this.topics,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      version: version ?? this.version,
      visibility: visibility ?? this.visibility,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'art_movements': artMovements,
      'created_at': createdAt.millisecondsSinceEpoch,
      'description': description,
      'dimensions': dimensions.toMap(),
      'extension': extension,
      'id': id,
      'license': license.toMap(),
      'name': name,
      'lore': lore,
      'size': size,
      'topics': topics,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'user_id': userId,
      'version': version,
      'visibility': visibilityToString(),
    };
  }

  String toJson() => json.encode(toMap());

  factory Illustration.fromJson(String source) =>
      Illustration.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Illustration(createdAt: $createdAt, description: $description, '
        'dimensions: $dimensions, extension: $extension, id: $id, '
        'license: $license, name: $name, lore: $lore, size: $size, '
        'styles: $artMovements, topics: $topics, updatedAt: $updatedAt, '
        'userId: $userId, version: $version, visibility: $visibility)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Illustration &&
        other.createdAt == createdAt &&
        other.description == description &&
        other.dimensions == dimensions &&
        other.extension == extension &&
        other.id == id &&
        other.license == license &&
        other.name == name &&
        other.lore == lore &&
        other.size == size &&
        listEquals(other.artMovements, artMovements) &&
        listEquals(other.topics, topics) &&
        other.updatedAt == updatedAt &&
        other.userId == userId &&
        other.version == version &&
        other.visibility == visibility;
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
        description.hashCode ^
        dimensions.hashCode ^
        extension.hashCode ^
        id.hashCode ^
        license.hashCode ^
        name.hashCode ^
        lore.hashCode ^
        size.hashCode ^
        artMovements.hashCode ^
        topics.hashCode ^
        updatedAt.hashCode ^
        userId.hashCode ^
        version.hashCode ^
        visibility.hashCode;
  }
}
