import 'package:artbooking/types/illustration/share_links.dart';
import 'package:artbooking/types/illustration/thumbnail_links.dart';
import 'package:artbooking/types/json_types.dart';

/// Links of a book/illustration including original image, thumbnails.
class MasterpieceLinks {
  const MasterpieceLinks({
    this.original = "",
    this.storage = "",
    required this.thumbnails,
    required this.share,
  });

  final String original;
  final ShareLinks share;
  final String storage;
  final ThumbnailLinks thumbnails;

  factory MasterpieceLinks.empty({
    String original = "",
    ThumbnailLinks? thumbnailLinks,
  }) {
    return MasterpieceLinks(
      original: original,
      share: ShareLinks.empty(),
      storage: "",
      thumbnails: thumbnailLinks ?? ThumbnailLinks.empty(),
    );
  }

  factory MasterpieceLinks.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return MasterpieceLinks.empty();
    }

    return MasterpieceLinks(
      original: data["original"] ?? "",
      share: ShareLinks.fromMap(data["share"]),
      storage: data["storage"] ?? "",
      thumbnails: ThumbnailLinks.fromMap(data["thumbnails"]),
    );
  }

  Json toMap() {
    return {
      "original": original,
      "share": share.toMap(),
      "storage": storage,
      "thumbnails": thumbnails.toMap(),
    };
  }
}
