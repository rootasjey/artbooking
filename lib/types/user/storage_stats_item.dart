class StorageStatsItem {
  final int total;
  final int used;

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
      total: data['total'] ?? 0,
      used: data['used'] ?? 0,
    );
  }
}
