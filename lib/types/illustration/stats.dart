import 'dart:convert';

class IllustrationStats {
  IllustrationStats({
    this.downloads = 0,
    this.likes = 0,
    this.shares = 0,
    this.views = 0,
  });

  /// How many times this illustration has been downloaded.
  final int downloads;

  /// How many likes has this illustration.
  final int likes;

  /// How many times this illustration has been shared.
  final int shares;

  /// How many times a user went to this illustration's page.
  final int views;

  factory IllustrationStats.empty() {
    return IllustrationStats(
      downloads: 0,
      likes: 0,
      shares: 0,
      views: 0,
    );
  }

  factory IllustrationStats.fromJSON(Map<String, dynamic> data) {
    return IllustrationStats(
      downloads: data['downloads'] ?? 0,
      likes: data['likes'] ?? 0,
      shares: data['shares'] ?? 0,
      views: data['views'] ?? 0,
    );
  }

  IllustrationStats copyWith({
    int? downloads,
    int? likes,
    int? shares,
    int? views,
  }) {
    return IllustrationStats(
      downloads: downloads ?? this.downloads,
      likes: likes ?? this.likes,
      shares: shares ?? this.shares,
      views: views ?? this.views,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'downloads': downloads,
      'likes': likes,
      'shares': shares,
      'views': views,
    };
  }

  factory IllustrationStats.fromMap(Map<String, dynamic> map) {
    return IllustrationStats(
      downloads: map['downloads']?.toInt() ?? 0,
      likes: map['likes']?.toInt() ?? 0,
      shares: map['shares']?.toInt() ?? 0,
      views: map['views']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory IllustrationStats.fromJson(String source) =>
      IllustrationStats.fromMap(json.decode(source));

  @override
  String toString() {
    return 'IllustrationStats(downloads: $downloads, likes: $likes, '
        'shares: $shares, views: $views)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IllustrationStats &&
        other.downloads == downloads &&
        other.likes == likes &&
        other.shares == shares &&
        other.views == views;
  }

  @override
  int get hashCode {
    return downloads.hashCode ^
        likes.hashCode ^
        shares.hashCode ^
        views.hashCode;
  }
}
