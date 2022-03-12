import 'dart:convert';

import 'package:artbooking/types/enums/enum_separator_shape.dart';

class HeaderSeparator {
  final int color;
  final EnumSeparatorShape shape;

  HeaderSeparator({
    required this.color,
    required this.shape,
  });

  HeaderSeparator copyWith({
    int? color,
    EnumSeparatorShape? separatorType,
  }) {
    return HeaderSeparator(
      color: color ?? this.color,
      shape: separatorType ?? this.shape,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "color": color,
      "shape": shape.name,
    };
  }

  factory HeaderSeparator.empty() {
    return HeaderSeparator(
      color: -1,
      shape: EnumSeparatorShape.none,
    );
  }

  factory HeaderSeparator.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return HeaderSeparator.empty();
    }

    return HeaderSeparator(
      color: map["color"]?.toInt() ?? 0,
      shape: parseShape(map["shape"]),
    );
  }

  static EnumSeparatorShape parseShape(String? shape) {
    if (shape == null) {
      return EnumSeparatorShape.none;
    }

    switch (shape) {
      case "dot":
        return EnumSeparatorShape.dot;
      case "line":
        return EnumSeparatorShape.line;
      case "none":
        return EnumSeparatorShape.none;
      default:
        return EnumSeparatorShape.none;
    }
  }

  String toJson() => json.encode(toMap());

  factory HeaderSeparator.fromJson(String source) =>
      HeaderSeparator.fromMap(json.decode(source));

  @override
  String toString() => 'SectionHeaderSeparator(color: $color, shape: $shape)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HeaderSeparator &&
        other.color == color &&
        other.shape == shape;
  }

  @override
  int get hashCode => color.hashCode ^ shape.hashCode;
}
