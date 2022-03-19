import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book_cover.dart';
import 'package:artbooking/types/book/book_illustration.dart';
import 'package:artbooking/types/enums/enum_book_layout.dart';
import 'package:artbooking/types/enums/enum_book_layout_orientation.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';

class Book {
  const Book({
    required this.cover,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.available = true,
    this.count = 0,
    this.description = "",
    this.id = "",
    this.illustrations = const [],
    this.layout = EnumBookLayout.grid,
    this.layoutOrientation = EnumBookLayoutOrientation.vertical,
    this.liked = false,
    this.name = "",
    this.userCustomIndex = 0,
    this.visibility = EnumContentVisibility.private,
  });

  /// If false, the book may have a visibility preventing access.
  /// Or this book may be deleted;
  final bool available;

  /// Number of illustrations in this book.
  final int count;

  /// Book's thumbnail.
  final BookCover cover;

  /// When this book was created.
  final DateTime createdAt;

  /// This book's description.
  final String description;

  /// Firestore's id.
  final String id;

  /// Each document inside the array is a simplified illustration document.
  /// Limited to 100 → Because a document is limited to 1MB in size.
  final List<BookIllustration> illustrations;

  /// Defines content layout and presentation.
  final EnumBookLayout layout;

  /// Defines layout scroll orientation.
  /// Will be used if [layout] value is {adaptativeGrid},
  /// {customGrid}, {customList}, {grid}, {smallGrid}, {largeGrid}.
  final EnumBookLayoutOrientation layoutOrientation;

  /// For small resolutions, defines layout scroll orientation.
  /// Will be used if [layout] value is {adaptativeGrid}, {customGrid},
  /// {customList}, {grid}, {smallGrid}, {largeGrid}.
  // EnumBookLayoutOrientation layoutOrientationMobile;

  /// True if the current authenticated user liked this book.
  /// This property does NOT exist as a Book's field in Firestore.
  /// I must be fetched from Book's subcollection `book_likes`.
  final bool liked;

  /// This book's name.
  final String name;

  /// Used when [layout] value is {extendedGrid}.
  /// This property is initially empty and is filled when {extendedGrid} is chosen.
  /// The initialisation can take some time
  /// because the data structure must be converted [illustrations] → [matrice]
  /// (array → array of arrays).
  /// When the conversion is done, [illustrations] property is cleared
  /// for space and sync purpose (free up space as doc is limited to 1MB
  /// and the cost to maintain 2 data structures updated is too high).
  // List<List<BookIllustration>> matrice;

  /// Last time this book was updated.
  final DateTime updatedAt;

  /// Urls of assets or other content.
  // final BookLinks links;

  final String userId;

  /// User defined index to reorder books in user's space.
  /// This property can be set by the user. By default,
  /// a new created book will take the next available index  (0, 1,...).
  final int userCustomIndex;

  /// Control if other people can view this book.
  final EnumContentVisibility visibility;

  factory Book.empty({
    String id = "",
    String name = "",
    String userId = "",
    bool available = false,
  }) {
    return Book(
      available: available,
      id: id,
      name: name,
      cover: BookCover.empty(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: userId,
    );
  }

  factory Book.fromMap(Map<String, dynamic> data) {
    return Book(
      count: data["count"]?.toInt() ?? 0,
      cover: BookCover.fromMap(data["cover"]),
      createdAt: Utilities.date.fromFirestore(data["created_at"]),
      description: data["description"] ?? "",
      id: data["id"] ?? "",
      illustrations: parseIllustrations(data["illustrations"]),
      layout: parseLayout(data["layout"]),
      layoutOrientation: parseOrientation(data["layout_orientation"]),
      liked: data["liked"] ?? false,
      name: data["name"] ?? "",
      updatedAt: Utilities.date.fromFirestore(data["updated_at"]),
      userId: data["user_id"] ?? "",
      userCustomIndex: data["user_custom_index"] ?? 0,
      visibility: parseStringVisibility(data["visibility"]),
    );
  }

  static List<BookIllustration> parseIllustrations(data) {
    final illustrations = <BookIllustration>[];

    if (data == null) {
      return illustrations;
    }

    for (var bookIllustrationData in data) {
      illustrations.add(BookIllustration.fromMap(bookIllustrationData));
    }

    return illustrations;
  }

  /// Return this book cover link.
  /// It can either be custom (manually set),
  /// auto (set to the last uploaded illustration),
  /// or default if the book is empty.
  String getCoverLink() {
    final thumbnails = cover.links.thumbnails;
    if (thumbnails.s.isNotEmpty) {
      return thumbnails.s;
    }

    if (thumbnails.m.isNotEmpty) {
      return thumbnails.m;
    }

    if (thumbnails.xs.isNotEmpty) {
      return thumbnails.xs;
    }

    if (thumbnails.l.isNotEmpty) {
      return thumbnails.l;
    }

    return "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fbooks%2Fmissing%2Fmissing_book_s.png?alt=media&token=ae32c8e3-af10-4e98-98dc-d4f144779ec9";
  }

  String layoutOrientationToString() {
    switch (layoutOrientation) {
      case EnumBookLayoutOrientation.both:
        return 'both';
      case EnumBookLayoutOrientation.horizontal:
        return 'horizontal';
      case EnumBookLayoutOrientation.vertical:
        return 'vertical';
      default:
        return 'vertical';
    }
  }

  String layoutToString() {
    switch (layout) {
      case EnumBookLayout.adaptativeGrid:
        return 'adaptativeGrid';
      case EnumBookLayout.customExtendedGrid:
        return 'customExtendedGrid';
      case EnumBookLayout.customGrid:
        return 'customGrid';
      case EnumBookLayout.customList:
        return 'customList';
      case EnumBookLayout.grid:
        return 'grid';
      case EnumBookLayout.horizontalList:
        return 'horizontalList';
      case EnumBookLayout.horizontalListWide:
        return 'horizontalListWide';
      case EnumBookLayout.largeGrid:
        return 'largeGrid';
      case EnumBookLayout.smallGrid:
        return 'smallGrid';
      case EnumBookLayout.twoPagesBook:
        return 'twoPagesBook';
      case EnumBookLayout.verticalList:
        return 'verticalList';
      case EnumBookLayout.verticalListWide:
        return 'verticalListWide';
      default:
        return 'grid';
    }
  }

  static EnumBookLayout parseLayout(String? stringLayout) {
    switch (stringLayout) {
      case 'adaptativeGrid':
        return EnumBookLayout.adaptativeGrid;
      case 'customExtendedGrid':
        return EnumBookLayout.customExtendedGrid;
      case 'customGrid':
        return EnumBookLayout.customGrid;
      case 'horizontalList':
        return EnumBookLayout.horizontalList;
      case 'horizontalListWide':
        return EnumBookLayout.horizontalListWide;
      case 'grid':
        return EnumBookLayout.grid;
      case 'largeGrid':
        return EnumBookLayout.largeGrid;
      case 'smallGrid':
        return EnumBookLayout.smallGrid;
      case 'twoPagesBook':
        return EnumBookLayout.twoPagesBook;
      case 'verticalList':
        return EnumBookLayout.verticalList;
      case 'verticalListWide':
        return EnumBookLayout.verticalListWide;
      default:
        return EnumBookLayout.adaptativeGrid;
    }
  }

  static EnumBookLayoutOrientation parseOrientation(String? stringOrientation) {
    switch (stringOrientation) {
      case "both":
        return EnumBookLayoutOrientation.both;
      case "horizontal":
        return EnumBookLayoutOrientation.horizontal;
      case "vertical":
        return EnumBookLayoutOrientation.vertical;
      default:
        return EnumBookLayoutOrientation.vertical;
    }
  }

  static EnumContentVisibility parseStringVisibility(String? stringVisibility) {
    switch (stringVisibility) {
      case "acl":
        return EnumContentVisibility.acl;
      case "archived":
        return EnumContentVisibility.archived;
      case "private":
        return EnumContentVisibility.private;
      case "public":
        return EnumContentVisibility.public;
      default:
        return EnumContentVisibility.private;
    }
  }

  Book copyWith({
    bool? available,
    int? count,
    BookCover? cover,
    DateTime? createdAt,
    String? description,
    String? id,
    List<BookIllustration>? illustrations,
    EnumBookLayout? layout,
    EnumBookLayoutOrientation? layoutOrientation,
    bool? liked,
    String? name,
    DateTime? updatedAt,
    String? userId,
    int? userCustomIndex,
    EnumContentVisibility? visibility,
  }) {
    return Book(
      available: available ?? this.available,
      count: count ?? this.count,
      cover: cover ?? this.cover,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      id: id ?? this.id,
      illustrations: illustrations ?? this.illustrations,
      layout: layout ?? this.layout,
      layoutOrientation: layoutOrientation ?? this.layoutOrientation,
      liked: liked ?? this.liked,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      userCustomIndex: userCustomIndex ?? this.userCustomIndex,
      visibility: visibility ?? this.visibility,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "count": count,
      "cover": cover.toMap(),
      "createdAt": createdAt.millisecondsSinceEpoch,
      "description": description,
      "id": id,
      "illustrations": illustrations.map((x) => x.toMap()).toList(),
      "layout": layoutToString(),
      "layoutOrientation": layoutOrientationToString(),
      "liked": liked,
      "name": name,
      "user_id": userId,
      "userCustomIndex": userCustomIndex,
      "visibility": visibility.name,
    };
  }

  String toJson() => json.encode(toMap());

  factory Book.fromJson(String source) => Book.fromMap(json.decode(source));

  @override
  String toString() {
    return "Book(available: $available, count: $count, cover: $cover, "
        "createdAt: $createdAt, description: $description, id: $id, "
        "illustrations: $illustrations, layout: $layout, "
        "layoutOrientation: $layoutOrientation, liked: $liked, name: $name,"
        " updatedAt: $updatedAt, userId: $userId, "
        "userCustomIndex: $userCustomIndex visibility: $visibility)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Book &&
        other.count == count &&
        other.cover == cover &&
        other.createdAt == createdAt &&
        other.description == description &&
        other.id == id &&
        listEquals(other.illustrations, illustrations) &&
        other.layout == layout &&
        other.layoutOrientation == layoutOrientation &&
        other.liked == liked &&
        other.name == name &&
        other.updatedAt == updatedAt &&
        other.userId == userId &&
        other.userCustomIndex == userCustomIndex &&
        other.visibility == visibility;
  }

  @override
  int get hashCode {
    return count.hashCode ^
        cover.hashCode ^
        createdAt.hashCode ^
        description.hashCode ^
        id.hashCode ^
        illustrations.hashCode ^
        layout.hashCode ^
        layoutOrientation.hashCode ^
        liked.hashCode ^
        name.hashCode ^
        updatedAt.hashCode ^
        userId.hashCode ^
        userCustomIndex.hashCode ^
        visibility.hashCode;
  }
}
