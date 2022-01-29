import 'dart:convert';

class StorageStatsItem {
  StorageStatsItem({
    required this.total,
    required this.used,
  });

  final int total;
  final int used;

  StorageStatsItem copyWith({
    int? total,
    int? used,
  }) {
    return StorageStatsItem(
      total: total ?? this.total,
      used: used ?? this.used,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'used': used,
    };
  }

  factory StorageStatsItem.empty() {
    return StorageStatsItem(
      total: 0,
      used: 0,
    );
  }

  factory StorageStatsItem.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return StorageStatsItem.empty();
    }

    return StorageStatsItem(
      total: map['total']?.toInt() ?? 0,
      used: map['used']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory StorageStatsItem.fromJson(String source) =>
      StorageStatsItem.fromMap(json.decode(source));

  @override
  String toString() => 'StorageStatsItem(total: $total, used: $used)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StorageStatsItem &&
        other.total == total &&
        other.used == used;
  }

  @override
  int get hashCode => total.hashCode ^ used.hashCode;
}
