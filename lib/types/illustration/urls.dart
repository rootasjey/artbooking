import 'package:artbooking/types/illustration/share_urls.dart';
import 'package:artbooking/types/illustration/thumbnail_urls.dart';

class Urls {
  Urls({
    this.original = '',
    this.storage = '',
    required this.thumbnails,
    required this.share,
  });

  String original;
  ShareUrls share;
  String storage;
  ThumbnailUrls thumbnails;

  factory Urls.empty() {
    return Urls(
      original: '',
      share: ShareUrls.empty(),
      storage: '',
      thumbnails: ThumbnailUrls.empty(),
    );
  }

  factory Urls.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return Urls.empty();
    }

    return Urls(
      original: data['original'] ?? '',
      share: ShareUrls.fromJSON(data['share']),
      storage: data['storage'] ?? '',
      thumbnails: ThumbnailUrls.fromJSON(data['thumbnails']),
    );
  }
}
