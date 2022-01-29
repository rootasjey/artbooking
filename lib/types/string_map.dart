import 'dart:convert';

class StringMap {
  final String edited;
  final String original;

  const StringMap({
    this.edited = '',
    this.original = '',
  });

  StringMap copyWith({
    String? edited,
    String? original,
  }) {
    return StringMap(
      edited: edited ?? this.edited,
      original: original ?? this.original,
    );
  }

  StringMap merge(StringMap userPPPath) {
    final newEdited = userPPPath.edited;
    final newOriginal = userPPPath.original;

    return StringMap(
      edited: newEdited.isNotEmpty ? newEdited : this.edited,
      original: newOriginal.isNotEmpty ? newOriginal : this.original,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'edited': edited,
      'original': original,
    };
  }

  factory StringMap.empty() {
    return StringMap();
  }

  factory StringMap.fromMap(Map<String, dynamic> map) {
    return StringMap(
      edited: map['edited'] ?? '',
      original: map['original'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory StringMap.fromJson(String source) =>
      StringMap.fromMap(json.decode(source));

  @override
  String toString() => 'StringMap(edited: $edited, original: $original)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StringMap &&
        other.edited == edited &&
        other.original == original;
  }

  @override
  int get hashCode => edited.hashCode ^ original.hashCode;
}
