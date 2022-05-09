import 'dart:convert';

import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/foundation.dart';

import 'package:artbooking/types/enums/enum_content_visibility.dart';

class Post {
  Post({
    required this.createdAt,
    required this.publishedAt,
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
    this.content = "",
  });

  final List<String> authors;
  final DateTime createdAt;
  final String description;
  final List<String> languages;
  final String name;
  final String storagePath;
  final String id;
  final DateTime publishedAt;
  final List<String> tags;
  final List<String> translations;
  final EnumContentVisibility visibility;
  final DateTime updatedAt;
  final int wordCount;
  final String iconData;
  final String content;

  factory Post.empty() {
    return Post(
      createdAt: DateTime.now(),
      publishedAt: DateTime.now(),
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
    String? content,
    DateTime? publishedAt,
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
      content: content ?? this.content,
      languages: languages ?? this.languages,
      name: name ?? this.name,
      storagePath: storagePath ?? this.storagePath,
      id: id ?? this.id,
      publishedAt: publishedAt ?? this.publishedAt,
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
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
      'description': description,
      'icon_data': iconData,
      'languages': languages,
      'name': name,
      'storagePath': storagePath,
      'id': id,
      'published_at': createdAt.millisecondsSinceEpoch,
      'tags': tags,
      'translations': translations,
      'visibility': visibility.name,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'wordCount': wordCount,
    };
  }

  Map<String, bool> tagsToMap() {
    final map = <String, bool>{};

    for (final String tag in tags) {
      map.putIfAbsent(tag, () => true);
    }

    return map;
  }

  factory Post.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Post.empty();
    }

    return Post(
      authors: parseMapToArray(map["authors"]),
      content: map["content"] ?? "",
      createdAt: Utilities.date.fromFirestore(map["created_at"]),
      description: map["description"] ?? "",
      iconData: map["icon_data"] ?? "",
      languages: parseMapToArray(map["languages"]),
      name: map["name"] ?? "",
      storagePath: map["storage_path"] ?? "",
      id: map["id"] ?? "",
      publishedAt: Utilities.date.fromFirestore(map["published_at"]),
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
    return "Post(authors: $authors, content: $content, createdAt: $createdAt, "
        "description: $description, iconData: $iconData, languages: $languages, "
        "name: $name, pubslihedAt: $publishedAt, id: $id, tags: $tags, "
        "storagePath: $storagePath, translations: $translations, "
        "updatedAt: $updatedAt, visibility: $visibility, wordCount: $wordCount)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Post &&
        content == content &&
        listEquals(other.authors, authors) &&
        other.createdAt == createdAt &&
        other.description == description &&
        listEquals(other.languages, languages) &&
        other.name == name &&
        other.storagePath == storagePath &&
        other.id == id &&
        other.publishedAt == publishedAt &&
        listEquals(other.tags, tags) &&
        listEquals(other.translations, translations) &&
        other.visibility == visibility &&
        other.updatedAt == updatedAt &&
        other.wordCount == wordCount;
  }

  @override
  int get hashCode {
    return authors.hashCode ^
        content.hashCode ^
        createdAt.hashCode ^
        description.hashCode ^
        languages.hashCode ^
        name.hashCode ^
        storagePath.hashCode ^
        id.hashCode ^
        publishedAt.hashCode ^
        tags.hashCode ^
        translations.hashCode ^
        visibility.hashCode ^
        updatedAt.hashCode ^
        wordCount.hashCode;
  }
}
