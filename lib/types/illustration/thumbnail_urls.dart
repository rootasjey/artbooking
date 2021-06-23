class ThumbnailUrls {
  /// Thumbnail with a width of 1920 pixels.
  final String? t1920;

  /// Thumbnail with a width of 2400 pixels.
  final String? t2400;

  /// Thumbnail with a width of 1080 pixels.
  final String? t1080;

  /// Thumbnail with a width of 720 pixels.
  final String? t720;

  /// Thumbnail with a width of 480 pixels.
  final String? t480;

  /// Thumbnail with a width of 360 pixels.
  final String? t360;

  ThumbnailUrls({
    this.t1920 = '',
    this.t2400 = '',
    this.t1080 = '',
    this.t720 = '',
    this.t480 = '',
    this.t360 = '',
  });

  factory ThumbnailUrls.empty() {
    return ThumbnailUrls();
  }

  factory ThumbnailUrls.fromJSON(Map<String, dynamic> json) {
    return ThumbnailUrls(
      t1920: json['t1920'],
      t2400: json['t2400'],
      t1080: json['t1080'],
      t720: json['t720'],
      t480: json['t480'],
      t360: json['t360'],
    );
  }
}
