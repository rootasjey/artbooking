import 'dart:convert';
import 'dart:math';

import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/illustration/dimensions.dart';
import 'package:artbooking/types/string_map.dart';

class ProfilePicture {
  const ProfilePicture({
    this.dimensions = const Dimensions(),
    this.extension = '',
    required this.links,
    required this.path,
    this.size = 0,
    this.type = '',
    required this.updatedAt,
  });

  static const List<String> _sampleAvatars = [
    "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Favatars%2Favatar_woman_1.png?alt=media&token=2ef023f4-53c8-466b-93e4-70f58e6067bb",
    "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Favatars%2Favatar_man_0.png?alt=media&token=2c8edef3-5e6f-4b84-a52b-2c9034951e20",
  ];

  final Dimensions dimensions;

  /// Picture extension.
  final String extension;
  final StringMap links;
  final StringMap path;
  final int size;
  final String type;
  final DateTime updatedAt;

  ProfilePicture copyWith({
    String? extension,
    int? size,
    DateTime? updatedAt,
    StringMap? path,
    StringMap? url,
  }) {
    return ProfilePicture(
      extension: extension ?? this.extension,
      size: size ?? this.size,
      updatedAt: updatedAt ?? this.updatedAt,
      path: path ?? this.path,
      links: url ?? this.links,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'extension': extension,
      'links': links.toMap(),
      'path': path.toMap(),
      'size': size,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ProfilePicture.empty() {
    return ProfilePicture(
      extension: '',
      size: 0,
      updatedAt: DateTime.now(),
      path: StringMap.empty(),
      links: StringMap(
        original: _sampleAvatars.elementAt(
          Random().nextInt(_sampleAvatars.length),
        ),
      ),
    );
  }

  factory ProfilePicture.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ProfilePicture.empty();
    }

    StringMap links = StringMap.fromMap(map['links']);

    if (links.original.isEmpty) {
      links = StringMap(
        original: _sampleAvatars.elementAt(
          Random().nextInt(_sampleAvatars.length),
        ),
      );
    }

    return ProfilePicture(
      dimensions: Dimensions.fromMap(map['dimensions']),
      extension: map['extension'] ?? '',
      links: links,
      path: StringMap.fromMap(map['path']),
      size: map['size']?.toInt() ?? 0,
      type: map['type'] ?? '',
      updatedAt: Utilities.date.fromFirestore(map['updated_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfilePicture.fromJson(String source) =>
      ProfilePicture.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ProfilePicture(extension: $extension, size: $size, '
        'updatedAt: $updatedAt, path: $path, url: $links)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProfilePicture &&
        other.extension == extension &&
        other.links == links &&
        other.path == path &&
        other.size == size &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return extension.hashCode ^
        links.hashCode ^
        size.hashCode ^
        path.hashCode ^
        updatedAt.hashCode;
  }
}
