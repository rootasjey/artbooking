import 'dart:convert';

import 'package:artbooking/globals/constants.dart';
import 'package:flutter/foundation.dart';

import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_section_data_type.dart';
import 'package:artbooking/types/enums/enum_section_size.dart';

/// Building block for Pages.
class Section {
  Section({
    required this.backgroundColor,
    required this.id,
    required this.description,
    required this.mode,
    required this.modes,
    required this.name,
    required this.items,
    required this.size,
    required this.sizes,
    required this.dataTypes,
  });

  /// Id of this section. It matches a specific design.
  final String id;

  /// Section's background color;
  final int backgroundColor;

  /// Best usage of this section.
  final String description;

  /// How this section's data is populated.
  final EnumSectionDataMode mode;

  /// Available mode to populate this section's data.
  final List<EnumSectionDataMode> modes;

  /// Human readable name.
  final String name;

  /// Item ids. Can match books or illustrations.
  final List<String> items;

  /// How large should this sectionn be?
  final EnumSectionSize size;

  /// List of available sizes this sectionn can have.
  final List<EnumSectionSize> sizes;

  /// What types of data this section consumes.
  final List<EnumSectionDataType> dataTypes;

  Section copyWith({
    int? backgroundColor,
    String? id,
    String? description,
    EnumSectionDataMode? mode,
    List<EnumSectionDataMode>? modes,
    String? name,
    List<String>? items,
    EnumSectionSize? size,
    List<EnumSectionSize>? sizes,
    List<EnumSectionDataType>? types,
  }) {
    return Section(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      id: id ?? this.id,
      description: description ?? this.description,
      mode: mode ?? this.mode,
      modes: modes ?? this.modes,
      name: name ?? this.name,
      items: items ?? this.items,
      size: size ?? this.size,
      sizes: sizes ?? this.sizes,
      dataTypes: types ?? this.dataTypes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "background_color": backgroundColor,
      'description': description,
      "id": id,
      "mode": sectionModeToString(mode),
      "modes": sectionModesToStrings(),
      "name": name,
      "items": items,
      "size": sectionSizeToString(size),
      "sizes": sectionSizesToStrings(),
      "dataTypes": sectionDataTypesToListString(),
    };
  }

  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      backgroundColor:
          map["background_color"] ?? Constants.colors.lightBackground.value,
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      mode: sectionModeFromString(map['mode']),
      modes: sectionModesFromStrings(map['modes']),
      name: map['name'] ?? '',
      items: map['items'] != null ? List<String>.from(map['items']) : [],
      size: sectionSizeFromString(map['size']),
      sizes: sectionSizesFromStrings(map['sizes']),
      dataTypes: sectionTypesFromString(map['data_types']),
    );
  }

  static String sectionModeToString(EnumSectionDataMode mode) {
    switch (mode) {
      case EnumSectionDataMode.chosen:
        return "chosen";
      case EnumSectionDataMode.sync:
        return "sync";
      default:
        return "sync";
    }
  }

  static EnumSectionDataMode sectionModeFromString(String? modeString) {
    if (modeString == null) {
      return EnumSectionDataMode.sync;
    }

    switch (modeString) {
      case "chosen":
        return EnumSectionDataMode.chosen;
      case "sync":
        return EnumSectionDataMode.sync;
      default:
        return EnumSectionDataMode.sync;
    }
  }

  List<String> sectionModesToStrings() {
    if (this.modes.isEmpty) {
      return [];
    }

    final List<String> modeList = [];

    for (var mode in this.modes) {
      modeList.add(sectionModeToString(mode));
    }

    return modeList;
  }

  static List<EnumSectionDataMode> sectionModesFromStrings(
    dynamic rawModeList,
  ) {
    if (rawModeList == null) {
      return [];
    }

    final List<EnumSectionDataMode> modeList = [];

    for (var modeStr in rawModeList) {
      modeList.add(sectionModeFromString(modeStr));
    }

    return modeList;
  }

  static EnumSectionSize sectionSizeFromString(String? sizeString) {
    if (sizeString == null) {
      return EnumSectionSize.large;
    }

    switch (sizeString) {
      case "large":
        return EnumSectionSize.large;
      case "medium":
        return EnumSectionSize.medium;
      default:
        return EnumSectionSize.large;
    }
  }

  static List<EnumSectionSize> sectionSizesFromStrings(rawSectionSizes) {
    if (rawSectionSizes == null) {
      return [];
    }

    final List<EnumSectionSize> sectionSizes = [];

    for (var size in rawSectionSizes) {
      sectionSizes.add(sectionSizeFromString(size));
    }

    return sectionSizes;
  }

  static String sectionSizeToString(EnumSectionSize size) {
    switch (size) {
      case EnumSectionSize.large:
        return "large";
      case EnumSectionSize.medium:
        return "medium";
      default:
        return "large";
    }
  }

  List<String> sectionSizesToStrings() {
    final List<String> sectionSizes = [];

    for (var size in sizes) {
      sectionSizes.add(sectionSizeToString(size));
    }

    return sectionSizes;
  }

  static List<EnumSectionDataType> sectionTypesFromString(
      dynamic rawSectionTypes) {
    if (rawSectionTypes == null) {
      return [];
    }

    final List<EnumSectionDataType> dataTypes = [];

    for (String dataType in rawSectionTypes) {
      switch (dataType) {
        case "books":
          dataTypes.add(EnumSectionDataType.books);
          break;
        case "illustrations":
          dataTypes.add(EnumSectionDataType.illustrations);
          break;
        case "user":
          dataTypes.add(EnumSectionDataType.user);
          break;
        default:
          break;
      }
    }

    return dataTypes;
  }

  List<String> sectionDataTypesToListString() {
    if (this.dataTypes.isEmpty) {
      return [];
    }

    final List<String> listString = [];

    for (var dataType in this.dataTypes) {
      switch (dataType) {
        case EnumSectionDataType.books:
          listString.add("books");
          break;
        case EnumSectionDataType.illustrations:
          listString.add("illustrations");
          break;
        case EnumSectionDataType.user:
          listString.add("user");
          break;
        default:
          break;
      }
    }

    return listString;
  }

  String toJson() => json.encode(toMap());

  factory Section.fromJson(String source) =>
      Section.fromMap(json.decode(source));

  @override
  String toString() {
    return "Section(id: $id,  backgroundColor: $backgroundColor, "
        "description: $description, mode: $mode, name: $name, "
        "items: $items, size: $size, types: $dataTypes)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Section &&
        other.id == id &&
        other.backgroundColor == backgroundColor &&
        other.description == description &&
        other.mode == mode &&
        listEquals(other.modes, modes) &&
        other.name == name &&
        listEquals(other.items, items) &&
        other.size == size &&
        listEquals(other.sizes, sizes) &&
        listEquals(other.dataTypes, dataTypes);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        backgroundColor.hashCode ^
        description.hashCode ^
        mode.hashCode ^
        modes.hashCode ^
        name.hashCode ^
        items.hashCode ^
        size.hashCode ^
        sizes.hashCode ^
        dataTypes.hashCode;
  }
}
