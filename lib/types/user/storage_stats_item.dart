import 'dart:convert';

import 'package:artbooking/globals/utilities.dart';

class StorageStatsItem {
  StorageStatsItem({
    this.total = 0,
    this.used = 0,
    required this.updatedAt,
  });

  final int total;
  final int used;

  /// Last time this statistic was updated.
  final DateTime updatedAt;

  StorageStatsItem copyWith({
    int? total,
    int? used,
    DateTime? updatedAt,
  }) {
    return StorageStatsItem(
      total: total ?? this.total,
      updatedAt: updatedAt ?? this.updatedAt,
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
      updatedAt: DateTime.now(),
    );
  }

  factory StorageStatsItem.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return StorageStatsItem.empty();
    }

    return StorageStatsItem(
      total: map['total']?.toInt() ?? 0,
      updatedAt: Utilities.date.fromFirestore(map['updated_at']),
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
