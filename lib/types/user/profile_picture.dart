import 'dart:convert';

import 'package:artbooking/types/string_map.dart';

class ProfilePicture {
  ProfilePicture({
    this.ext = '',
    this.size = 0,
    this.updatedAt,
    required this.path,
    required this.url,
  });

  /// Picture extension.
  String ext;
  int size;
  DateTime? updatedAt;
  StringMap path;
  StringMap url;

  ProfilePicture copyWith({
    String? ext,
    int? size,
    DateTime? updatedAt,
    StringMap? path,
    StringMap? url,
  }) {
    return ProfilePicture(
      ext: ext ?? this.ext,
      size: size ?? this.size,
      updatedAt: updatedAt ?? this.updatedAt,
      path: path ?? this.path,
      url: url ?? this.url,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ext': ext,
      'size': size,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'path': path.toMap(),
      'url': url.toMap(),
    };
  }

  factory ProfilePicture.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ProfilePicture.empty();
    }

    return ProfilePicture(
      ext: map['ext'] ?? '',
      size: map['size']?.toInt() ?? 0,
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      path: StringMap.fromMap(map['path']),
      url: StringMap.fromMap(map['url']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfilePicture.fromJson(String source) =>
      ProfilePicture.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ProfilePicture(ext: $ext, size: $size, updatedAt: $updatedAt, path: $path, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProfilePicture &&
        other.ext == ext &&
        other.size == size &&
        other.updatedAt == updatedAt &&
        other.path == path &&
        other.url == url;
  }

  @override
  int get hashCode {
    return ext.hashCode ^
        size.hashCode ^
        updatedAt.hashCode ^
        path.hashCode ^
        url.hashCode;
  }

  void merge({
    String? ext,
    int? size,
    StringMap? path,
    StringMap? url,
  }) {
    if (ext != null) {
      this.ext = ext;
    }

    if (size != null) {
      this.size = size;
    }

    this.updatedAt = DateTime.now();

    if (path != null) {
      this.path = this.path.merge(path);
    }

    if (url != null) {
      this.url = this.url.merge(url);
    }
  }

  void update(ProfilePicture userPP) {
    ext = userPP.ext;
    size = userPP.size;
    updatedAt = userPP.updatedAt;
    path = userPP.path;
    url = userPP.url;
  }

  factory ProfilePicture.empty() {
    return ProfilePicture(
      ext: '',
      size: 0,
      updatedAt: DateTime.now(),
      path: StringMap.empty(),
      url: StringMap.empty(),
    );
  }
}
