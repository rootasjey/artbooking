import 'dart:convert';

import 'package:artbooking/types/book/scale_factor.dart';

/// A class with a id and a scale factor.
/// This is mainly used as an item in a grid with variable item size.
/// (BookIllustration had unwanted additional properties)
class SizedIllustration {
  const SizedIllustration({
    required this.id,
    required this.scaleFactor,
  });

  /// Illustration's id.
  final String id;

  /// Defines this illustration's side inside this book.
  final ScaleFactor scaleFactor;

  factory SizedIllustration.fromMap(Map<String, dynamic> data) {
    return SizedIllustration(
      id: data["id"],
      scaleFactor: ScaleFactor.fromMap(data["scale_factor"]),
    );
  }

  SizedIllustration copyWith({
    String? id,
    DateTime? createdAt,
    ScaleFactor? scaleFactor,
  }) {
    return SizedIllustration(
      id: id ?? this.id,
      scaleFactor: scaleFactor ?? this.scaleFactor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "scale_factor": scaleFactor.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  factory SizedIllustration.fromJson(String source) =>
      SizedIllustration.fromMap(json.decode(source));

  @override
  String toString() => 'BookIllustration(id: $id, scaleFactor: $scaleFactor)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SizedIllustration &&
        other.id == id &&
        other.scaleFactor == scaleFactor;
  }

  @override
  int get hashCode => id.hashCode ^ scaleFactor.hashCode;
}
