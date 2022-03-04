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
    required this.dataMode,
    required this.dataModes,
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
  final EnumSectionDataMode dataMode;

  /// Available modes to populate this section's data.
  final List<EnumSectionDataMode> dataModes;

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
    EnumSectionDataMode? dataMode,
    List<EnumSectionDataMode>? dataModes,
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
      dataMode: dataMode ?? this.dataMode,
      dataModes: dataModes ?? this.dataModes,
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
      "data_mode": sectionModeToString(dataMode),
      "data_modes": sectionModesToStrings(),
      "name": name,
      "items": items,
      "size": sectionSizeToString(size),
      "sizes": sectionSizesToStrings(),
      "dataTypes": sectionDataTypesToListString(),
    };
  }

  factory Section.fromMap(Map<String, dynamic> map) {
    final int backgroundColor =
        map["background_color"] ?? Constants.colors.lightBackground.value;

    return Section(
      backgroundColor: backgroundColor,
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      dataMode: sectionModeFromString(map['data_mode']),
      dataModes: sectionModesFromStrings(map['data_modes']),
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
    if (this.dataModes.isEmpty) {
      return [];
    }

    final List<String> modeList = [];

    for (var mode in this.dataModes) {
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
        "description: $description, dataMode: $dataMode, "
        "dataModes: $dataModes, name: $name, items: $items, size: $size, "
        "types: $dataTypes)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Section &&
        other.id == id &&
        other.backgroundColor == backgroundColor &&
        other.description == description &&
        other.dataMode == dataMode &&
        listEquals(other.dataModes, dataModes) &&
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
        dataMode.hashCode ^
        dataModes.hashCode ^
        name.hashCode ^
        items.hashCode ^
        size.hashCode ^
        sizes.hashCode ^
        dataTypes.hashCode;
  }
}
