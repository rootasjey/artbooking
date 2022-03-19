import 'dart:convert';

class ShareLinks {
  ShareLinks({
    required this.read,
    required this.write,
  });

  final String read;
  final String write;

  factory ShareLinks.empty() {
    return ShareLinks(
      read: "",
      write: "",
    );
  }

  factory ShareLinks.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ShareLinks.empty();
    }

    return ShareLinks(
      read: map["read"] ?? "",
      write: map["write"] ?? "",
    );
  }

  ShareLinks copyWith({
    String? read,
    String? write,
  }) {
    return ShareLinks(
      read: read ?? this.read,
      write: write ?? this.write,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "read": read,
      "write": write,
    };
  }

  String toJson() => json.encode(toMap());

  factory ShareLinks.fromJson(String source) =>
      ShareLinks.fromMap(json.decode(source));

  @override
  String toString() => "ShareLinks(read: $read, write: $write)";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShareLinks && other.read == read && other.write == write;
  }

  @override
  int get hashCode => read.hashCode ^ write.hashCode;
}
