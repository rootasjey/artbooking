class ThumbnailUrls {
  String s1024;
  String s128;
  String s512;
  String s64;

  ThumbnailUrls({
    this.s1024 = '',
    this.s128 = '',
    this.s512 = '',
    this.s64 = '',
  });

  factory ThumbnailUrls.empty() {
    return ThumbnailUrls();
  }

  factory ThumbnailUrls.fromJSON(Map<String, dynamic> json) {
    return ThumbnailUrls(
      s1024: json['s1024'],
      s128: json['s128'],
      s512: json['s512'],
      s64: json['s64'],
    );
  }
}
