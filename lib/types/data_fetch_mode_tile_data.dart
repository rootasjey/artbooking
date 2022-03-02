import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:flutter/widgets.dart';

class DataFetchModeTileData {
  DataFetchModeTileData({
    required this.name,
    required this.description,
    required this.iconData,
    required this.mode,
  });

  final String name;
  final String description;
  final IconData iconData;
  final EnumSectionDataMode mode;

  DataFetchModeTileData copyWith({
    String? name,
    String? description,
    IconData? icon,
    EnumSectionDataMode? mode,
  }) {
    return DataFetchModeTileData(
      mode: mode ?? this.mode,
      name: name ?? this.name,
      description: description ?? this.description,
      iconData: icon ?? this.iconData,
    );
  }

  @override
  String toString() => 'DataFetchModeTileData(name: $name, '
      'description: $description, mode: $mode, iconData: $iconData)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DataFetchModeTileData &&
        other.name == name &&
        other.mode == mode &&
        other.description == description &&
        other.iconData == iconData;
  }

  @override
  int get hashCode =>
      mode.hashCode ^ name.hashCode ^ description.hashCode ^ iconData.hashCode;
}
