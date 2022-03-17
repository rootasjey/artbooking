import 'dart:convert';

import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_book_cover_mode.dart';

class BookCover {
  const BookCover({
    required this.mode,
    required this.link,
    required this.updatedAt,
  });

  final BookCoverMode mode;
  final String link;
  final DateTime? updatedAt;

  factory BookCover.empty() {
    return BookCover(
      mode: BookCoverMode.lastIllustrationAdded,
      link: "https://firebasestorage.googleapis.com/v0/b/"
          "artbooking-54d22.appspot.com/o/static%2Fimages%2Fbook_cover_512x683.png"
          "?alt=media&token=d77bc23b-90d7-4663-be3a-e878c6403e51",
      updatedAt: DateTime.now(),
    );
  }

  factory BookCover.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return BookCover.empty();
    }

    return BookCover(
      link: data["link"],
      updatedAt: Utilities.date.fromFirestore(data["updated_at"]),
      mode: parseBookCoverMode(data["mode"]),
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
    String? link,
    DateTime? updatedAt,
  }) {
    return BookCover(
      mode: mode ?? this.mode,
      link: link ?? this.link,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "mode": modeToString(),
      "link": link,
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
      "BookCover(mode: $mode, link: $link, updatedAt: $updatedAt)";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookCover &&
        other.mode == mode &&
        other.link == link &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => mode.hashCode ^ link.hashCode ^ updatedAt.hashCode;
}
