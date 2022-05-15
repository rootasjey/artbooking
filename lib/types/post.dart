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
    this.characterCount = 0,
    this.content = "",
    this.language = "en",
    this.description = "",
    this.iconData = "",
    this.id = "",
    this.languages = const [],
    this.name = "",
    this.storagePath = "",
    this.tags = const [],
    this.translations = const [],
    this.userIds = const [],
    this.wordCount = 0,
  });

  /// Firebase Storage file content.
  /// This property doesn't exist in Firestore.
  final String content;

  /// Date when this post was created.
  final DateTime createdAt;

  /// Number of character in this post's content.
  final int characterCount;

  /// Post description, subtitle or catch phrase.
  final String description;
  final String iconData;

  /// Post's language.
  final String language;
  final List<String> languages;

  /// Post's title.
  final String name;

  /// Post's unique Fireastore id.
  final String id;

  /// Date when it was published.
  final DateTime publishedAt;

  /// Firebase Storage path.
  final String storagePath;

  /// Post's topics.
  final List<String> tags;

  /// Translated posts (same content).
  final List<String> translations;

  /// Date when this post was last updated.
  final DateTime updatedAt;

  /// Author ids of this post.
  final List<String> userIds;

  /// Defines which user can see this post.
  final EnumContentVisibility visibility;

  /// Number of words in this post's content.
  final int wordCount;

  factory Post.empty() {
    return Post(
      createdAt: DateTime.now(),
      publishedAt: DateTime.now(),
      visibility: EnumContentVisibility.private,
      updatedAt: DateTime.now(),
    );
  }

  Post copyWith({
    String? content,
    int? characterCount,
    DateTime? createdAt,
    String? description,
    String? iconData,
    String? id,
    String? language,
    List<String>? languages,
    String? name,
    DateTime? publishedAt,
    String? storagePath,
    List<String>? tags,
    List<String>? translations,
    List<String>? userIds,
    DateTime? updatedAt,
    EnumContentVisibility? visibility,
    int? wordCount,
  }) {
    return Post(
      characterCount: characterCount ?? this.characterCount,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      content: content ?? this.content,
      iconData: iconData ?? this.iconData,
      id: id ?? this.id,
      language: language ?? this.language,
      languages: languages ?? this.languages,
      name: name ?? this.name,
      storagePath: storagePath ?? this.storagePath,
      publishedAt: publishedAt ?? this.publishedAt,
      tags: tags ?? this.tags,
      translations: translations ?? this.translations,
      updatedAt: updatedAt ?? this.updatedAt,
      userIds: userIds ?? this.userIds,
      visibility: visibility ?? this.visibility,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'character_count': characterCount,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
      'description': description,
      'icon_data': iconData,
      'language': language,
      'languages': languages,
      'name': name,
      'storagePath': storagePath,
      'id': id,
      'published_at': createdAt.millisecondsSinceEpoch,
      'tags': listToMapStringBool(tags),
      'translations': translations,
      'visibility': visibility.name,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'userIds': listToMapStringBool(userIds),
      'wordCount': wordCount,
    };
  }

  Map<String, bool> listToMapStringBool(List<String> list) {
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
      characterCount: map["character_count"]?.toInt() ?? 0,
      content: map["content"] ?? "",
      createdAt: Utilities.date.fromFirestore(map["created_at"]),
      description: map["description"] ?? "",
      iconData: map["icon_data"] ?? "",
      languages: parseMapToArray(map["languages"]),
      language: map["language"] ?? "en",
      name: map["name"] ?? "",
      storagePath: map["storage_path"] ?? "",
      id: map["id"] ?? "",
      publishedAt: Utilities.date.fromFirestore(map["published_at"]),
      tags: parseMapToArray(map["tags"]),
      translations: parseMapToArray(map["translations"]),
      visibility: parseVisibility(map["visibility"]),
      updatedAt: Utilities.date.fromFirestore(map["updated_at"]),
      userIds: parseMapToArray(map["user_ids"]),
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
    return "Post(content: $content, createdAt: $createdAt, characterCount: $characterCount, "
        "description: $description, iconData: $iconData, language: $language, "
        "languages: $languages, name: $name, pubslihedAt: $publishedAt, id: $id, "
        "tags: $tags, storagePath: $storagePath, translations: $translations, "
        "updatedAt: $updatedAt, userIds: $userIds, visibility: $visibility, "
        "wordCount: $wordCount)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Post &&
        other.characterCount == characterCount &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.description == description &&
        other.id == id &&
        other.language == language &&
        listEquals(other.languages, languages) &&
        other.name == name &&
        other.publishedAt == publishedAt &&
        other.storagePath == storagePath &&
        listEquals(other.tags, tags) &&
        listEquals(other.translations, translations) &&
        other.visibility == visibility &&
        other.updatedAt == updatedAt &&
        listEquals(other.userIds, userIds) &&
        other.wordCount == wordCount;
  }

  @override
  int get hashCode {
    return characterCount.hashCode ^
        content.hashCode ^
        createdAt.hashCode ^
        description.hashCode ^
        id.hashCode ^
        language.hashCode ^
        languages.hashCode ^
        name.hashCode ^
        publishedAt.hashCode ^
        storagePath.hashCode ^
        tags.hashCode ^
        translations.hashCode ^
        updatedAt.hashCode ^
        userIds.hashCode ^
        visibility.hashCode ^
        wordCount.hashCode;
  }
}
