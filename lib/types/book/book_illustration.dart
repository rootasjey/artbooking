import 'dart:convert';

import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/scale_factor.dart';

class BookIllustration {
  const BookIllustration({
    required this.id,
    required this.createdAt,
    required this.scaleFactor,
  });

  /// Illustration's id.
  final String id;

  /// When this illustration was added to the parent book.
  final DateTime createdAt;

  /// Defines this illustration's side inside this book.
  final ScaleFactor scaleFactor;

  factory BookIllustration.fromMap(Map<String, dynamic> data) {
    return BookIllustration(
      createdAt: Utilities.date.fromFirestore(data['created_at']),
      id: data['id'],
      scaleFactor: ScaleFactor.fromMap(data['scale_factor']),
    );
  }

  BookIllustration copyWith({
    String? id,
    DateTime? createdAt,
    ScaleFactor? scaleFactor,
  }) {
    return BookIllustration(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      scaleFactor: scaleFactor ?? this.scaleFactor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'scaleFactor': scaleFactor.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  factory BookIllustration.fromJson(String source) =>
      BookIllustration.fromMap(json.decode(source));

  @override
  String toString() =>
      'BookIllustration(id: $id, createdAt: $createdAt, scaleFactor: $scaleFactor)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookIllustration &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.scaleFactor == scaleFactor;
  }

  @override
  int get hashCode => id.hashCode ^ createdAt.hashCode ^ scaleFactor.hashCode;
}
