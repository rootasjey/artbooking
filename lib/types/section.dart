import 'dart:convert';

import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_section_visibility.dart';
import 'package:artbooking/types/header_separator.dart';
import 'package:flutter/foundation.dart';

import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_section_data_type.dart';
import 'package:artbooking/types/enums/enum_section_size.dart';
import 'package:flutter/material.dart';

/// Building block for Pages.
class Section {
  Section({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.createdAt,
    required this.dataTypes,
    required this.description,
    required this.dataFetchMode,
    required this.dataFetchModes,
    required this.headerSeparator,
    required this.id,
    required this.items,
    required this.name,
    required this.size,
    required this.sizes,
    required this.updatedAt,
    required this.visibility,
  });

  /// Id of this section. It matches a specific design.
  final String id;

  /// Section's background color;
  final int backgroundColor;

  /// Section's border color;
  final int borderColor;

  /// Section's text color;
  final int textColor;

  /// When this entry was created in Firestore.
  final DateTime createdAt;

  /// Best usage of this section.
  final String description;

  /// How this section's data is fetched (manual, sync).
  final EnumSectionDataMode dataFetchMode;

  /// Available data fetch modes to populate this section's data.
  final List<EnumSectionDataMode> dataFetchModes;

  final HeaderSeparator headerSeparator;

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

  /// Last time this license was updated.
  final DateTime updatedAt;

  final EnumSectionVisibility visibility;

  Section copyWith({
    int? backgroundColor,
    int? borderColor,
    int? textColor,
    String? id,
    DateTime? createdAt,
    String? description,
    EnumSectionDataMode? dataFetchMode,
    List<EnumSectionDataMode>? dataFetchModes,
    HeaderSeparator? headerSeparator,
    String? name,
    List<String>? items,
    EnumSectionSize? size,
    List<EnumSectionSize>? sizes,
    List<EnumSectionDataType>? dataTypes,
    DateTime? updatedAt,
    EnumSectionVisibility? visibility,
  }) {
    return Section(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      createdAt: createdAt ?? this.createdAt,
      dataTypes: dataTypes ?? this.dataTypes,
      description: description ?? this.description,
      dataFetchMode: dataFetchMode ?? this.dataFetchMode,
      dataFetchModes: dataFetchModes ?? this.dataFetchModes,
      headerSeparator: headerSeparator ?? this.headerSeparator,
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      size: size ?? this.size,
      sizes: sizes ?? this.sizes,
      textColor: textColor ?? this.textColor,
      updatedAt: updatedAt ?? this.updatedAt,
      visibility: visibility ?? this.visibility,
    );
  }

  Map<String, dynamic> toMap({bool withId = true}) {
    final map = {
      "background_color": backgroundColor,
      "border_color": borderColor,
      "data_mode": dataFetchModeToString(dataFetchMode),
      "data_modes": dataFetchModesToStrings(),
      "data_types": dataTypesToStrings(),
      "description": description,
      "header_separator": headerSeparator.toMap(),
      "name": name,
      "items": items,
      "size": sectionSizeToString(size),
      "sizes": sectionSizesToStrings(),
      "text_color": textColor,
      "visibility": visibilityToString(),
    };

    if (withId) {
      map["id"] = id;
    }

    return map;
  }

  factory Section.empty() {
    return Section(
      backgroundColor: Constants.colors.lightBackground.value,
      borderColor: Constants.colors.lightBackground.value,
      createdAt: DateTime.now(),
      dataFetchMode: EnumSectionDataMode.chosen,
      dataFetchModes: [],
      dataTypes: [],
      description: "",
      headerSeparator: HeaderSeparator.empty(),
      id: "",
      name: "",
      items: [],
      size: EnumSectionSize.large,
      sizes: [],
      textColor: Colors.black.value,
      updatedAt: DateTime.now(),
      visibility: EnumSectionVisibility.public,
    );
  }

  factory Section.fromMap(Map<String, dynamic> map) {
    final int backgroundColor =
        map["background_color"] ?? Constants.colors.lightBackground.value;

    final int borderColor = map["border_color"] ?? Colors.transparent.value;

    final int textColor = map["text_color"] ?? Colors.black.value;

    return Section(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      createdAt: Utilities.date.fromFirestore(map["created_at"]),
      dataTypes: stringsToDataTypes(map["data_types"]),
      description: map["description"] ?? "",
      dataFetchMode: stringToDataFetchMode(map["data_mode"]),
      dataFetchModes: stringsToDataFetchModes(map["data_modes"]),
      headerSeparator: HeaderSeparator.fromMap(map["header_separator"]),
      id: map["id"] ?? "",
      items: map["items"] != null ? List<String>.from(map["items"]) : [],
      name: map["name"] ?? "",
      size: stringToSize(map["size"]),
      sizes: stringsToSizes(map["sizes"]),
      textColor: textColor,
      updatedAt: Utilities.date.fromFirestore(map["updated_at"]),
      visibility: stringToVisibility(map["visibility"]),
    );
  }

  static String dataFetchModeToString(EnumSectionDataMode dataFetchMode) {
    switch (dataFetchMode) {
      case EnumSectionDataMode.chosen:
        return "chosen";
      case EnumSectionDataMode.sync:
        return "sync";
      default:
        return "sync";
    }
  }

  static EnumSectionVisibility stringToVisibility(String? visibilityString) {
    if (visibilityString == null) {
      return EnumSectionVisibility.public;
    }

    switch (visibilityString) {
      case "public":
        return EnumSectionVisibility.public;
      case "staff":
        return EnumSectionVisibility.staff;
      default:
        return EnumSectionVisibility.public;
    }
  }

  static EnumSectionDataMode stringToDataFetchMode(String? modeString) {
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

  List<String> dataFetchModesToStrings() {
    if (this.dataFetchModes.isEmpty) {
      return [];
    }

    final List<String> modeList = [];

    for (var mode in this.dataFetchModes) {
      modeList.add(dataFetchModeToString(mode));
    }

    return modeList;
  }

  static List<EnumSectionDataMode> stringsToDataFetchModes(
    dynamic strings,
  ) {
    if (strings == null) {
      return [];
    }

    final List<EnumSectionDataMode> dataFetchModes = [];

    for (var string in strings) {
      dataFetchModes.add(stringToDataFetchMode(string));
    }

    return dataFetchModes;
  }

  static EnumSectionSize stringToSize(String? string) {
    if (string == null) {
      return EnumSectionSize.large;
    }

    switch (string) {
      case "large":
        return EnumSectionSize.large;
      case "medium":
        return EnumSectionSize.medium;
      default:
        return EnumSectionSize.large;
    }
  }

  static List<EnumSectionSize> stringsToSizes(strings) {
    if (strings == null) {
      return [];
    }

    final List<EnumSectionSize> sizes = [];

    for (var string in strings) {
      sizes.add(stringToSize(string));
    }

    return sizes;
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

  static List<EnumSectionDataType> stringsToDataTypes(dynamic strings) {
    if (strings == null) {
      return [];
    }

    final List<EnumSectionDataType> dataTypes = [];

    for (String string in strings) {
      switch (string) {
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

  List<String> dataTypesToStrings() {
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

  String visibilityToString() {
    switch (visibility) {
      case EnumSectionVisibility.public:
        return "public";
      case EnumSectionVisibility.staff:
        return "staff";
      default:
        return "public";
    }
  }

  String toJson() => json.encode(toMap());

  factory Section.fromJson(String source) =>
      Section.fromMap(json.decode(source));

  @override
  String toString() {
    return "Section(id: $id,  backgroundColor: $backgroundColor, "
        "borderColor: $borderColor"
        "createdAt: ${createdAt.toString()} description: $description, "
        "dataFetchMode: $dataFetchMode, dataModes: $dataFetchModes, "
        "headerSeparator: $headerSeparator"
        "name: $name, items: $items, size: $size, textColor: $textColor "
        "types: $dataTypes, updatedAt: ${updatedAt.toString()},"
        "visibility: ${visibility.name})";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Section &&
        other.id == id &&
        other.borderColor == borderColor &&
        other.createdAt == createdAt &&
        other.backgroundColor == backgroundColor &&
        other.dataFetchMode == dataFetchMode &&
        listEquals(other.dataFetchModes, dataFetchModes) &&
        listEquals(other.dataTypes, dataTypes) &&
        other.description == description &&
        other.headerSeparator == headerSeparator &&
        other.name == name &&
        listEquals(other.items, items) &&
        other.size == size &&
        listEquals(other.sizes, sizes) &&
        other.textColor == textColor &&
        other.updatedAt == updatedAt &&
        other.visibility == visibility;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        backgroundColor.hashCode ^
        borderColor ^
        createdAt.hashCode ^
        dataTypes.hashCode ^
        description.hashCode ^
        dataFetchMode.hashCode ^
        dataFetchModes.hashCode ^
        headerSeparator.hashCode ^
        name.hashCode ^
        items.hashCode ^
        size.hashCode ^
        sizes.hashCode ^
        textColor.hashCode ^
        updatedAt.hashCode ^
        visibility.hashCode;
  }
}
