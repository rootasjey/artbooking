class ThumbnailUrls {
  String t1024;
  String t128;
  String t512;
  String t64;

  ThumbnailUrls({
    this.t1024 = '',
    this.t128 = '',
    this.t512 = '',
    this.t64 = '',
  });

  factory ThumbnailUrls.empty() {
    return ThumbnailUrls();
  }

  factory ThumbnailUrls.fromJSON(Map<String, dynamic> json) {
    return ThumbnailUrls(
      t1024: json['t1024'],
      t128: json['t128'],
      t512: json['t512'],
      t64: json['t64'],
    );
  }
}
