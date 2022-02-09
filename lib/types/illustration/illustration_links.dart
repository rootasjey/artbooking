import 'package:artbooking/types/illustration/share_links.dart';
import 'package:artbooking/types/illustration/thumbnail_links.dart';

class IllustrationLinks {
  const IllustrationLinks({
    this.original = '',
    this.storage = '',
    required this.thumbnails,
    required this.share,
  });

  final String original;
  final ShareLinks share;
  final String storage;
  final ThumbnailLinks thumbnails;

  factory IllustrationLinks.empty() {
    return IllustrationLinks(
      original: '',
      share: ShareLinks.empty(),
      storage: '',
      thumbnails: ThumbnailLinks.empty(),
    );
  }

  factory IllustrationLinks.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return IllustrationLinks.empty();
    }

    return IllustrationLinks(
      original: data['original'] ?? '',
      share: ShareLinks.fromMap(data['share']),
      storage: data['storage'] ?? '',
      thumbnails: ThumbnailLinks.fromMap(data['thumbnails']),
    );
  }
}
