import 'dart:convert';

import 'package:artbooking/types/user/storage_stats_item.dart';

class UserStorageStats {
  UserStorageStats({
    required this.illustrations,
    required this.videos,
  });

  /// Number of existing illustrations this user own.
  StorageStatsItem illustrations;

  /// Total illustrations updates by providing a new version.
  StorageStatsItem videos;

  UserStorageStats copyWith({
    StorageStatsItem? illustrations,
    StorageStatsItem? videos,
  }) {
    return UserStorageStats(
      illustrations: illustrations ?? this.illustrations,
      videos: videos ?? this.videos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'illustrations': illustrations.toMap(),
      'videos': videos.toMap(),
    };
  }

  factory UserStorageStats.empty() {
    return UserStorageStats(
      illustrations: StorageStatsItem.empty(),
      videos: StorageStatsItem.empty(),
    );
  }

  factory UserStorageStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserStorageStats.empty();
    }

    return UserStorageStats(
      illustrations: StorageStatsItem.fromMap(map['illustrations']),
      videos: StorageStatsItem.fromMap(map['videos']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserStorageStats.fromJson(String source) =>
      UserStorageStats.fromMap(json.decode(source));

  @override
  String toString() =>
      'UserStorageStats(illustrations: $illustrations, videos: $videos)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserStorageStats &&
        other.illustrations == illustrations &&
        other.videos == videos;
  }

  @override
  int get hashCode => illustrations.hashCode ^ videos.hashCode;
}
