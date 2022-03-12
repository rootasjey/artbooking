import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:flutter/widgets.dart';

class TileData<T> {
  TileData({
    required this.name,
    required this.description,
    required this.iconData,
    required this.type,
  });

  final String name;
  final String description;
  final IconData iconData;
  final T type;

  TileData copyWith({
    String? name,
    String? description,
    IconData? icon,
    EnumSectionDataMode? mode,
  }) {
    return TileData(
      type: mode ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      iconData: icon ?? this.iconData,
    );
  }

  @override
  String toString() => 'DataFetchModeTileData(name: $name, '
      'description: $description, type: $type, iconData: $iconData)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TileData &&
        other.name == name &&
        other.type == type &&
        other.description == description &&
        other.iconData == iconData;
  }

  @override
  int get hashCode =>
      type.hashCode ^ name.hashCode ^ description.hashCode ^ iconData.hashCode;
}
