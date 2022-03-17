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
      original:
          "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fillustrations%2Fmissing_illustration_2048.png?alt=media&token=558532de-9cea-4968-8578-d35b81192c84",
      share: ShareLinks.empty(),
      storage: "",
      thumbnails: ThumbnailLinks.empty(),
    );
  }

  factory IllustrationLinks.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return IllustrationLinks.empty();
    }

    return IllustrationLinks(
      original: data['original'] ?? "",
      share: ShareLinks.fromMap(data['share']),
      storage: data['storage'] ?? "",
      thumbnails: ThumbnailLinks.fromMap(data['thumbnails']),
    );
  }
}
