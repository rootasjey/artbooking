class ShareUrls {
  String read;
  String write;

  ShareUrls({
    this.read = '',
    this.write = '',
  });

  factory ShareUrls.empty() {
    return ShareUrls(
      read: '',
      write: '',
    );
  }

  factory ShareUrls.fromJSON(Map<String, dynamic> json) {
    return ShareUrls(
      read: json['read'],
      write: json['write'],
    );
  }
}
