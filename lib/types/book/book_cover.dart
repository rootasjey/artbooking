import 'dart:convert';

import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_book_cover_mode.dart';
import 'package:artbooking/types/illustration/share_links.dart';
import 'package:artbooking/types/illustration/thumbnail_links.dart';
import 'package:artbooking/types/masterpiece_links.dart';

class BookCover {
  const BookCover({
    required this.mode,
    required this.updatedAt,
    required this.links,
  });

  final BookCoverMode mode;
  final DateTime? updatedAt;
  final MasterpieceLinks links;

  factory BookCover.empty() {
    return BookCover(
      mode: BookCoverMode.lastIllustrationAdded,
      links: MasterpieceLinks(
        share: ShareLinks.empty(),
        thumbnails: ThumbnailLinks(),
      ),
      updatedAt: DateTime.now(),
    );
  }

  factory BookCover.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return BookCover.empty();
    }

    return BookCover(
      mode: parseBookCoverMode(data["mode"]),
      links: MasterpieceLinks.fromMap(data["links"]),
      updatedAt: Utilities.date.fromFirestore(data["updated_at"]),
    );
  }

  static BookCoverMode parseBookCoverMode(String rawMode) {
    switch (rawMode) {
      case "last_illustration_added":
        return BookCoverMode.lastIllustrationAdded;
      case "chosen_illustration":
        return BookCoverMode.chosenIllustration;
      case "custom_cover":
        return BookCoverMode.customCover;
      default:
        return BookCoverMode.lastIllustrationAdded;
    }
  }

  BookCover copyWith({
    BookCoverMode? mode,
    MasterpieceLinks? links,
    DateTime? updatedAt,
  }) {
    return BookCover(
      mode: mode ?? this.mode,
      links: links ?? this.links,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "mode": modeToString(),
      "links": links.toMap(),
    };
  }

  String modeToString() {
    switch (mode) {
      case BookCoverMode.chosenIllustration:
        return "chosen_illustration";
      case BookCoverMode.customCover:
        return "custom_cover";
      case BookCoverMode.lastIllustrationAdded:
        return "last_illustration_added";
      default:
        return "last_illustration_added";
    }
  }

  String toJson() => json.encode(toMap());

  factory BookCover.fromJson(String source) =>
      BookCover.fromMap(json.decode(source));

  @override
  String toString() =>
      "BookCover(mode: $mode, links: $links, updatedAt: $updatedAt)";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookCover &&
        other.mode == mode &&
        other.links == links &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => mode.hashCode ^ links.hashCode ^ updatedAt.hashCode;
}
