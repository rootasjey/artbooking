import 'dart:convert';

import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/foundation.dart';

import 'package:artbooking/types/enums/enum_page_type.dart';
import 'package:artbooking/types/section.dart';

/// Artistic page. Used for user's profile.
class ArtisticPage {
  const ArtisticPage({
    required this.id,
    required this.createdAt,
    this.isActive = false,
    this.isDraft = false,
    this.name = '',
    this.type = EnumPageType.profile,
    required this.updatedAt,
    this.sections = const [],
  });

  final String id;
  final DateTime createdAt;
  final bool isActive;
  final bool isDraft;
  final String name;
  final EnumPageType type;
  final DateTime updatedAt;
  final List<Section> sections;

  ArtisticPage copyWith({
    String? id,
    DateTime? createdAt,
    bool? isActive,
    bool? isDraft,
    String? name,
    EnumPageType? type,
    DateTime? updatedAt,
    List<Section>? sections,
  }) {
    return ArtisticPage(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      isDraft: isDraft ?? this.isDraft,
      name: name ?? this.name,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
      sections: sections ?? this.sections,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_active': isActive,
      'is_draft': isDraft,
      'name': name,
      'type': convertTypeToString(),
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sections': sections.map((x) => x.toMap()).toList(),
    };
  }

  factory ArtisticPage.empty() {
    return ArtisticPage(
      id: '',
      createdAt: DateTime.now(),
      isActive: false,
      isDraft: true,
      name: '',
      type: EnumPageType.profile,
      updatedAt: DateTime.now(),
      sections: [],
    );
  }

  factory ArtisticPage.fromMap(Map<String, dynamic> map) {
    return ArtisticPage(
      id: map['id'] ?? '',
      createdAt: Utilities.date.fromFirestore(map['created_at']),
      isActive: map['is_active'] ?? false,
      isDraft: map['is_draft'] ?? false,
      name: map['name'] ?? '',
      type: fromStringToType(map['type']),
      updatedAt: Utilities.date.fromFirestore(map['updated_at']),
      sections: List<Section>.from(
        map['sections']?.map((x) => Section.fromMap(x)),
      ),
    );
  }

  static EnumPageType fromStringToType(typeString) {
    if (typeString == null) {
      return EnumPageType.profile;
    }

    switch (typeString) {
      case "profile":
        return EnumPageType.profile;
      default:
        return EnumPageType.profile;
    }
  }

  String convertTypeToString() {
    switch (this.type) {
      case EnumPageType.profile:
        return "profile";
      default:
        return "profile";
    }
  }

  String toJson() => json.encode(toMap());

  factory ArtisticPage.fromJson(String source) =>
      ArtisticPage.fromMap(json.decode(source));

  @override
  String toString() {
    return "Page(id: $id, createdAt: $createdAt, isActive: $isActive, "
        "isDraft: $isDraft, name: $name, type: $type, "
        "updatedAt: $updatedAt, sections: $sections)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ArtisticPage &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.isActive == isActive &&
        other.isDraft == isDraft &&
        other.name == name &&
        other.type == type &&
        other.updatedAt == updatedAt &&
        listEquals(other.sections, sections);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        createdAt.hashCode ^
        isActive.hashCode ^
        isDraft.hashCode ^
        name.hashCode ^
        type.hashCode ^
        updatedAt.hashCode ^
        sections.hashCode;
  }
}
