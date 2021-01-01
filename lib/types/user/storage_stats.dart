import 'package:artbooking/types/user/storage_stats_item.dart';

class UserStorageStats {
  /// Number of existing illustrations this user own.
  StorageStatsItem images;

  /// Total illustrations updates by providing a new version.
  StorageStatsItem videos;

  UserStorageStats({this.images, this.videos});

  factory UserStorageStats.fromJSON(Map<String, dynamic> data) {
    return UserStorageStats(
      images: StorageStatsItem.fromJSON(data['images']),
      videos: StorageStatsItem.fromJSON(data['videos']),
    );
  }
}
