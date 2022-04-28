import 'dart:convert';

import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/foundation.dart';

import 'package:artbooking/types/enums/enum_content_visibility.dart';

class Post {
  Post({
    required this.createdAt,
    required this.updatedAt,
    required this.visibility,
    this.authors = const [],
    this.description = "",
    this.languages = const [],
    this.name = "",
    this.storagePath = "",
    this.id = "",
    this.tags = const [],
    this.translations = const [],
    this.wordCount = 0,
    this.iconData = "",
  });

  final List<String> authors;
  final DateTime createdAt;
  final String description;
  final List<String> languages;
  final String name;
  final String storagePath;
  final String id;
  final List<String> tags;
  final List<String> translations;
  final EnumContentVisibility visibility;
  final DateTime updatedAt;
  final int wordCount;
  final String iconData;

  factory Post.empty() {
    return Post(
      createdAt: DateTime.now(),
      visibility: EnumContentVisibility.private,
      updatedAt: DateTime.now(),
    );
  }

  Post copyWith({
    List<String>? authors,
    DateTime? createdAt,
    String? description,
    List<String>? languages,
    String? name,
    String? storagePath,
    String? id,
    String? iconData,
    List<String>? tags,
    List<String>? translations,
    EnumContentVisibility? visibility,
    DateTime? updatedAt,
    int? wordCount,
  }) {
    return Post(
      authors: authors ?? this.authors,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      iconData: iconData ?? this.iconData,
      languages: languages ?? this.languages,
      name: name ?? this.name,
      storagePath: storagePath ?? this.storagePath,
      id: id ?? this.id,
      tags: tags ?? this.tags,
      translations: translations ?? this.translations,
      visibility: visibility ?? this.visibility,
      updatedAt: updatedAt ?? this.updatedAt,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authors': authors,
      'created_at': createdAt.millisecondsSinceEpoch,
      'description': description,
      'icon_data': iconData,
      'languages': languages,
      'name': name,
      'storagePath': storagePath,
      'id': id,
      'tags': tags,
      'translations': translations,
      'visibility': visibility.name,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'wordCount': wordCount,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      authors: parseMapToArray(map["authors"]),
      createdAt: Utilities.date.fromFirestore(map["created_at"]),
      description: map["description"] ?? "",
      iconData: map["icon_data"] ?? "",
      languages: parseMapToArray(map["languages"]),
      name: map["name"] ?? "",
      storagePath: map["storage_path"] ?? "",
      id: map["id"] ?? "",
      tags: parseMapToArray(map["tags"]),
      translations: parseMapToArray(map["translations"]),
      visibility: parseVisibility(map["visibility"]),
      updatedAt: Utilities.date.fromFirestore(map["updated_at"]),
      wordCount: map["word_count"]?.toInt() ?? 0,
    );
  }

  static parseMapToArray(Map<String, dynamic>? authorMap) {
    final results = <String>[];

    if (authorMap == null) {
      return results;
    }

    authorMap.forEach((key, value) {
      results.add(key);
    });

    return results;
  }

  static EnumContentVisibility parseVisibility(String? stringVisibility) {
    if (stringVisibility == null) {
      return EnumContentVisibility.private;
    }

    switch (stringVisibility) {
      case "private":
        return EnumContentVisibility.private;
      case "public":
        return EnumContentVisibility.public;
      case "acl":
        return EnumContentVisibility.acl;
      case "archived":
        return EnumContentVisibility.archived;
      default:
        return EnumContentVisibility.private;
    }
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));

  @override
  String toString() {
    return "Post(authors: $authors, createdAt: $createdAt, "
        "description: $description, iconData: $iconData, languages: $languages, "
        "name: $name, storagePath: $storagePath, id: $id, tags: $tags, "
        "translations: $translations, visibility: $visibility, "
        "updatedAt: $updatedAt, wordCount: $wordCount)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Post &&
        listEquals(other.authors, authors) &&
        other.createdAt == createdAt &&
        other.description == description &&
        listEquals(other.languages, languages) &&
        other.name == name &&
        other.storagePath == storagePath &&
        other.id == id &&
        listEquals(other.tags, tags) &&
        listEquals(other.translations, translations) &&
        other.visibility == visibility &&
        other.updatedAt == updatedAt &&
        other.wordCount == wordCount;
  }

  @override
  int get hashCode {
    return authors.hashCode ^
        createdAt.hashCode ^
        description.hashCode ^
        languages.hashCode ^
        name.hashCode ^
        storagePath.hashCode ^
        id.hashCode ^
        tags.hashCode ^
        translations.hashCode ^
        visibility.hashCode ^
        updatedAt.hashCode ^
        wordCount.hashCode;
  }
}
