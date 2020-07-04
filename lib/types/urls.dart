import 'package:artbooking/types/share_urls.dart';
import 'package:artbooking/types/thumbnail_urls.dart';

class Urls {
  String original;
  ShareUrls share;
  String storage;
  ThumbnailUrls thumbnail;

  Urls({
    this.original = '',
    this.storage = '',
    this.thumbnail,
    this.share,
  });

  factory Urls.fromJSON(Map<String, dynamic> json) {
    return Urls(
      original: json['original'],
      share: ShareUrls.fromJSON(json['share']),
      storage: json['storage'],
      thumbnail: ThumbnailUrls.fromJSON(json['thumbnail']),
    );
  }
}
