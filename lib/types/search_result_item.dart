import 'dart:convert';

import 'package:artbooking/types/enums/enum_search_item_type.dart';

/// Class representation of a piece of result.
class SearchResultItem {
  SearchResultItem({
    required this.type,
    required this.index,
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  /// This result can represent different type of data
  /// (e.g. book, illustration, user).
  final EnumSearchItemType type;

  /// Position in a list.
  final int index;

  /// Result identifier.
  /// (This result identifier may belong to an book, illustration, or user)
  final String id;

  /// This result's name.
  final String name;

  /// Visual representation of this result as an image url.
  final String imageUrl;

  SearchResultItem copyWith({
    EnumSearchItemType? type,
    int? index,
    String? id,
    String? name,
    String? imageUrl,
  }) {
    return SearchResultItem(
      type: type ?? this.type,
      index: index ?? this.index,
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'index': index,
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  factory SearchResultItem.fromMap(Map<String, dynamic> map) {
    return SearchResultItem(
      type: parseType(map["type"]),
      index: map["index"]?.toInt() ?? 0,
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      imageUrl: map["imageUrl"] ?? "",
    );
  }

  static EnumSearchItemType parseType(String typeStr) {
    switch (typeStr) {
      case "book":
        return EnumSearchItemType.book;
      case "illustration":
        return EnumSearchItemType.illustration;
      case "book":
        return EnumSearchItemType.book;
      default:
        return EnumSearchItemType.book;
    }
  }

  String toJson() => json.encode(toMap());

  factory SearchResultItem.fromJson(String source) =>
      SearchResultItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SearchResultItem(type: $type, index: $index, id: $id, name: $name, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchResultItem &&
        other.type == type &&
        other.index == index &&
        other.id == id &&
        other.name == name &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        index.hashCode ^
        id.hashCode ^
        name.hashCode ^
        imageUrl.hashCode;
  }
}
