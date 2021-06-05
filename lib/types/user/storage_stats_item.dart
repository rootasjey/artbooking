class StorageStatsItem {
  int total;
  int used;

  StorageStatsItem({
    this.total = 0,
    this.used = 0,
  });

  factory StorageStatsItem.empty() {
    return StorageStatsItem(
      total: 0,
      used: 0,
    );
  }

  factory StorageStatsItem.fromJSON(Map<String, dynamic> data) {
    return StorageStatsItem(
      total: data['total'],
      used: data['used'],
    );
  }
}
