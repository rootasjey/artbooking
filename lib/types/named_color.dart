import 'dart:convert';

import 'package:flutter/widgets.dart';

class NamedColor {
  NamedColor({
    required this.name,
    required this.color,
  });

  final String name;
  final Color color;

  NamedColor copyWith({
    String? name,
    Color? color,
  }) {
    return NamedColor(
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color.value,
    };
  }

  factory NamedColor.fromMap(Map<String, dynamic> map) {
    return NamedColor(
      name: map['name'] ?? '',
      color: Color(map['color']),
    );
  }

  String toJson() => json.encode(toMap());

  factory NamedColor.fromJson(String source) =>
      NamedColor.fromMap(json.decode(source));

  @override
  String toString() => 'NamedColor(name: $name, color: $color)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NamedColor && other.name == name && other.color == color;
  }

  @override
  int get hashCode => name.hashCode ^ color.hashCode;
}
