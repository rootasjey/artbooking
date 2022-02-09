import 'dart:convert';

class StringMap {
  const StringMap({
    this.edited = '',
    this.original = '',
    this.storage = '',
  });

  final String edited;
  final String original;
  final String storage;

  StringMap copyWith({
    String? edited,
    String? original,
    String? storage,
  }) {
    return StringMap(
      edited: edited ?? this.edited,
      original: original ?? this.original,
      storage: storage ?? this.storage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'edited': edited,
      'original': original,
      'storage': storage,
    };
  }

  factory StringMap.empty() {
    return StringMap();
  }

  factory StringMap.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return StringMap.empty();
    }

    return StringMap(
      edited: map['edited'] ?? '',
      original: map['original'] ?? '',
      storage: map['storage'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory StringMap.fromJson(String source) =>
      StringMap.fromMap(json.decode(source));

  @override
  String toString() => 'StringMap(edited: $edited, original: $original, '
      'storage: $storage)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StringMap &&
        other.edited == edited &&
        other.storage == storage &&
        other.original == original;
  }

  @override
  int get hashCode => edited.hashCode ^ original.hashCode ^ storage.hashCode;
}
