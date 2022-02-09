class ThumbnailLinks {
  const ThumbnailLinks({
    this.t1920 = '',
    this.t2400 = '',
    this.t1080 = '',
    this.t720 = '',
    this.t480 = '',
    this.t360 = '',
  });

  /// Thumbnail with a width of 1920 pixels.
  final String t1920;

  /// Thumbnail with a width of 2400 pixels.
  final String t2400;

  /// Thumbnail with a width of 1080 pixels.
  final String t1080;

  /// Thumbnail with a width of 720 pixels.
  final String t720;

  /// Thumbnail with a width of 480 pixels.
  final String t480;

  /// Thumbnail with a width of 360 pixels.
  final String t360;

  factory ThumbnailLinks.empty() {
    return ThumbnailLinks();
  }

  factory ThumbnailLinks.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return ThumbnailLinks.empty();
    }

    return ThumbnailLinks(
      t1920: data['t1920'] ?? '',
      t2400: data['t2400'] ?? '',
      t1080: data['t1080'] ?? '',
      t720: data['t720'] ?? '',
      t480: data['t480'] ?? '',
      t360: data['t360'] ?? '',
    );
  }
}
