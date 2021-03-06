import 'package:artbooking/types/user/storage_stats_item.dart';

class UserStorageStats {
  /// Number of existing illustrations this user own.
  StorageStatsItem? illustrations;

  /// Total illustrations updates by providing a new version.
  StorageStatsItem? videos;

  UserStorageStats({this.illustrations, this.videos});

  factory UserStorageStats.empty() {
    return UserStorageStats(
      illustrations: StorageStatsItem.empty(),
      videos: StorageStatsItem.empty(),
    );
  }

  factory UserStorageStats.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return UserStorageStats.empty();
    }

    return UserStorageStats(
      illustrations: StorageStatsItem.fromJSON(data['illustrations']),
      videos: StorageStatsItem.fromJSON(data['videos']),
    );
  }
}
