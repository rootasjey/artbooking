import 'dart:convert';
import 'dart:math';

import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/illustration/dimensions.dart';
import 'package:artbooking/types/string_map.dart';

class ProfilePicture {
  const ProfilePicture({
    this.extension = '',
    this.size = 0,
    required this.updatedAt,
    required this.path,
    required this.url,
    this.type = '',
    this.dimensions = const Dimensions(),
  });

  static const List<String> _sampleAvatars = [
    "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Favatar_female.png?alt=media&token=24de34ec-71a6-44d0-8324-50c77e848dee",
    "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Favatar_male.png?alt=media&token=326302d9-912d-4923-9bec-94c6bb9892ae",
  ];

  /// Picture extension.
  final String extension;
  final int size;
  final DateTime updatedAt;
  final StringMap path;
  final StringMap url;
  final String type;
  final Dimensions dimensions;

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
      url: url ?? this.url,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'extension': extension,
      'size': size,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'path': path.toMap(),
      'url': url.toMap(),
    };
  }

  factory ProfilePicture.empty() {
    return ProfilePicture(
      extension: '',
      size: 0,
      updatedAt: DateTime.now(),
      path: StringMap.empty(),
      url: StringMap(
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

    StringMap url = StringMap.fromMap(map['url']);
    if (url.original.isEmpty) {
      url = StringMap(
        original: _sampleAvatars.elementAt(
          Random().nextInt(_sampleAvatars.length),
        ),
      );
    }

    return ProfilePicture(
      extension: map['extension'] ?? '',
      size: map['size']?.toInt() ?? 0,
      updatedAt: Utilities.date.fromFirestore(map['updatedAt']),
      path: StringMap.fromMap(map['path']),
      url: url,
      type: map['type'] ?? '',
      dimensions: Dimensions.fromJSON(map['dimensions']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfilePicture.fromJson(String source) =>
      ProfilePicture.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ProfilePicture(extension: $extension, size: $size, updatedAt: $updatedAt, '
        'path: $path, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProfilePicture &&
        other.extension == extension &&
        other.size == size &&
        other.updatedAt == updatedAt &&
        other.path == path &&
        other.url == url;
  }

  @override
  int get hashCode {
    return extension.hashCode ^
        size.hashCode ^
        updatedAt.hashCode ^
        path.hashCode ^
        url.hashCode;
  }
}
