import 'package:artbooking/types/share_urls.dart';
import 'package:artbooking/types/illustration/thumbnail_urls.dart';

class Urls {
  String original;
  ShareUrls share;
  String storage;
  ThumbnailUrls thumbnails;

  Urls({
    this.original = '',
    this.storage = '',
    this.thumbnails,
    this.share,
  });

  factory Urls.fromJSON(Map<String, dynamic> json) {
    return Urls(
      original: json['original'],
      share: ShareUrls.fromJSON(json['share']),
      storage: json['storage'],
      thumbnails: ThumbnailUrls.fromJSON(json['thumbnails']),
    );
  }
}
