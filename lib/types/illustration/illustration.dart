import 'dart:convert';

import 'package:artbooking/types/illustration/thumbnail_links.dart';
import 'package:flutter/foundation.dart';

import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/illustration/dimensions.dart';
import 'package:artbooking/types/masterpiece_links.dart';
import 'package:artbooking/types/illustration/illustration_version.dart';
import 'package:artbooking/types/license/license.dart';

class Illustration {
  const Illustration({
    required this.createdAt,
    required this.dimensions,
    required this.license,
    required this.links,
    required this.updatedAt,
    this.artMovements = const [],
    this.description = '',
    this.extension = '',
    this.id = '',
    this.liked = false,
    this.name = '',
    this.size = 0,
    this.lore = '',
    this.topics = const [],
    this.userId = '',
    this.version = 0,
    this.visibility = EnumContentVisibility.private,
    this.userCustomIndex = 0,
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

  /// True if this is book is liked by the current authenticated user.
  /// This property does NOT exist on the Firestore document, but in
  /// a dedicated sub-collection.
  final bool liked;

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
  final MasterpieceLinks links;

  final String userId;

  /// User defined index to reorder illustrations in user's space.
  /// This property can be set by the user. By default,
  /// a new created illustration will take the next available index  (0, 1,...).
  final int userCustomIndex;

  /// Number of times the image has been updated & overwritten.
  /// When this value is 0, it means that the image is being upload
  /// and not available yet. The value is updated to 1 when image upload, and
  /// thumbnails generation are done.
  final int version;

  /// Access control policy.
  /// Define who can read or write this illustration.
  final EnumContentVisibility visibility;

  factory Illustration.empty({
    String id = "",
    String userId = "",
  }) {
    return Illustration(
      artMovements: const [],
      createdAt: DateTime.now(),
      description: "",
      dimensions: Dimensions.empty(),
      extension: "",
      id: id,
      license: License.empty(),
      name: "",
      size: 0,
      lore: "",
      topics: const [],
      updatedAt: DateTime.now(),
      links: MasterpieceLinks.empty(
        original:
            "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fillustrations%2Fmissing_illustration_2048.png?alt=media&token=558532de-9cea-4968-8578-d35b81192c84",
        thumbnailLinks: ThumbnailLinks.empty(),
      ),
      userId: userId,
      userCustomIndex: 0,
      version: 0,
      visibility: EnumContentVisibility.private,
    );
  }

  factory Illustration.fromMap(Map<String, dynamic> data) {
    return Illustration(
      artMovements: parseArtMovements(data["art_movements"]),
      createdAt: Utilities.date.fromFirestore(data["created_at"]),
      description: data["description"] ?? "",
      dimensions: Dimensions.fromMap(data["dimensions"]),
      extension: data["extension"] ?? "",
      id: data["id"] ?? "",
      license: License.fromMap(data["license"]),
      liked: data["liked"] ?? false,
      links: MasterpieceLinks.fromMap(data["links"]),
      lore: data["lore"] ?? "",
      name: data["name"] ?? "",
      size: data["size"] ?? 0,
      topics: parseTopics(data["topics"]),
      updatedAt: Utilities.date.fromFirestore(data["updated_at"]),
      userId: data["user_id"] ?? "",
      userCustomIndex: data["user_custom_index"] ?? 0,
      version: data["version"] ?? 0,
      visibility: parseVisibility(data["visibility"]),
    );
  }

  String getHDThumbnail() {
    final String small = links.thumbnails.m;

    if (small.isNotEmpty) {
      return small;
    }

    final String large = links.thumbnails.l;
    if (large.isNotEmpty) {
      return large;
    }

    return links.original;
  }

  String getThumbnail() {
    final String extraSmall = links.thumbnails.xs;
    if (extraSmall.isNotEmpty) {
      return extraSmall;
    }

    final String small = links.thumbnails.s;
    if (small.isNotEmpty) {
      return small;
    }

    final String medium = links.thumbnails.m;
    if (medium.isNotEmpty) {
      return medium;
    }

    final String large = links.thumbnails.l;
    if (large.isNotEmpty) {
      return large;
    }

    final String extraLarge = links.thumbnails.xxl;
    if (extraLarge.isNotEmpty) {
      return extraLarge;
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
      case "acl":
        return EnumContentVisibility.acl;
      case "archived":
        return EnumContentVisibility.archived;
      case "private":
        return EnumContentVisibility.private;
      case "public":
        return EnumContentVisibility.public;
      default:
        return EnumContentVisibility.private;
    }
  }

  Illustration copyWith({
    DateTime? createdAt,
    String? description,
    Dimensions? dimensions,
    String? extension,
    String? id,
    License? license,
    bool? liked,
    String? name,
    MasterpieceLinks? links,
    String? lore,
    int? size,
    List<String>? styles,
    List<String>? topics,
    DateTime? updatedAt,
    String? userId,
    int? version,
    int? userCustomIndex,
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
      liked: liked ?? this.liked,
      name: name ?? this.name,
      lore: lore ?? this.lore,
      size: size ?? this.size,
      artMovements: styles ?? this.artMovements,
      topics: topics ?? this.topics,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      userCustomIndex: userCustomIndex ?? this.userCustomIndex,
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
      'liked': liked,
      'name': name,
      'lore': lore,
      'size': size,
      'topics': topics,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'user_id': userId,
      'user_custom_index': userCustomIndex,
      'version': version,
      'visibility': visibility.name,
    };
  }

  String toJson() => json.encode(toMap());

  factory Illustration.fromJson(String source) =>
      Illustration.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Illustration(createdAt: $createdAt, description: $description, '
        'dimensions: $dimensions, extension: $extension, id: $id, '
        'license: $license, liked: $liked, name: $name, lore: $lore, '
        'size: $size,  styles: $artMovements, topics: $topics, '
        'updatedAt: $updatedAt, userId: $userId, '
        'userCustomIndex: $userCustomIndex, version: $version, '
        'visibility: $visibility)';
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
        other.liked == liked &&
        other.name == name &&
        other.lore == lore &&
        other.size == size &&
        listEquals(other.artMovements, artMovements) &&
        listEquals(other.topics, topics) &&
        other.updatedAt == updatedAt &&
        other.userId == userId &&
        other.userCustomIndex == userCustomIndex &&
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
        liked.hashCode ^
        name.hashCode ^
        lore.hashCode ^
        size.hashCode ^
        artMovements.hashCode ^
        topics.hashCode ^
        updatedAt.hashCode ^
        userId.hashCode ^
        userCustomIndex.hashCode ^
        version.hashCode ^
        visibility.hashCode;
  }
}
