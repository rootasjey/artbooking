class ThumbnailUrls {
  String t1080;
  String t720;
  String t480;
  String t360;

  ThumbnailUrls({
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
      t1080: json['t1080'],
      t720: json['t720'],
      t480: json['t480'],
      t360: json['t360'],
    );
  }
}
