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
    return ThumbnailLinks(
      t360:
          "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fillustrations%2Fmissing_illustration_360.png?alt=media&token=44664f38-eeb7-4392-8a43-74c05dcb56f4",
      t480:
          "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fillustrations%2Fmissing_illustration_480.png?alt=media&token=5471f355-4e25-4783-a5dc-544adc62d34b",
      t720:
          "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fillustrations%2Fmissing_illustration_720.png?alt=media&token=295c6b98-ede7-41f9-819d-87b7a59766ea",
      t1080:
          "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fillustrations%2Fmissing_illustration_1024.png?alt=media&token=61775649-95cf-4b68-895f-77476a743d83",
    );
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
