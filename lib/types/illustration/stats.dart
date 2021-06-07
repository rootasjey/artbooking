class IllustrationStats {
  /// How many times this illustration has been downloaded.
  final int downloads;

  /// How many likes has this illustration.
  final int fav;

  /// How many times this illustration has been shared.
  final int shares;

  /// How many times a user went to this illustration's page.
  final int views;

  IllustrationStats({
    this.downloads,
    this.fav,
    this.shares,
    this.views,
  });

  factory IllustrationStats.empty() {
    return IllustrationStats(
      downloads: 0,
      fav: 0,
      shares: 0,
      views: 0,
    );
  }

  factory IllustrationStats.fromJSON(Map<String, dynamic> data) {
    return IllustrationStats(
      downloads: data['downloads'],
      fav: data['fav'],
      shares: data['shares'],
      views: data['views'],
    );
  }
}
