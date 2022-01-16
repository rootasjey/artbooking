import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book_cover.dart';
import 'package:artbooking/types/book/book_illustration.dart';
import 'package:artbooking/types/book/book_urls.dart';
import 'package:artbooking/types/enums/enum_book_layout.dart';
import 'package:artbooking/types/enums/enum_book_layout_orientation.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';

class Book {
  /// Number of illustrations in this book.
  final int count;

  /// Book's thumbnail.
  final BookCover cover;

  /// When this book was created.
  final DateTime? createdAt;

  /// This book's description.
  String description;

  /// Firestore's id.
  final String id;

  /// Each document inside the array is a simplified illustration document.
  /// Limited to 100 → Because a document is limited to 1MB in size.
  List<BookIllustration> illustrations;

  /// Defines content layout and presentation.
  EnumBookLayout layout;

  /// Defines content layout and presentation for small screens.
  EnumBookLayout layoutMobile;

  /// Defines layout scroll orientation.
  /// Will be used if [layout] value is {adaptativeGrid},
  /// {customGrid}, {customList}, {grid}, {smallGrid}, {largeGrid}.
  EnumBookLayoutOrientation layoutOrientation;

  /// For small resolutions, defines layout scroll orientation.
  /// Will be used if [layout] value is {adaptativeGrid}, {customGrid},
  /// {customList}, {grid}, {smallGrid}, {largeGrid}.
  EnumBookLayoutOrientation layoutOrientationMobile;

  /// This book's name.
  String name;

  /// Used when [layout] value is {extendedGrid}.
  /// This property is initially empty and is filled when {extendedGrid} is chosen.
  /// The initialisation can take some time
  /// because the data structure must be converted [illustrations] → [matrice]
  /// (array → array of arrays).
  /// When the conversion is done, [illustrations] property is cleared
  /// for space and sync purpose (free up space as doc is limited to 1MB
  /// and the cost to maintain 2 data structures updated is too high).
  List<List<BookIllustration>> matrice;

  /// Last time this book was updated.
  final DateTime? updatedAt;

  /// Urls of assets or other content.
  final BookUrls urls;

  /// Control if other people can view this book.
  final EnumContentVisibility visibility;

  Book({
    this.count = 0,
    required this.cover,
    this.createdAt,
    this.description = '',
    this.id = '',
    this.illustrations = const [],
    this.layout = EnumBookLayout.grid,
    this.layoutMobile = EnumBookLayout.verticalList,
    this.layoutOrientation = EnumBookLayoutOrientation.vertical,
    this.layoutOrientationMobile = EnumBookLayoutOrientation.vertical,
    this.matrice = const [[]],
    this.name = '',
    this.updatedAt,
    required this.urls,
    this.visibility = EnumContentVisibility.private,
  });

  factory Book.fromJSON(Map<String, dynamic> data) {
    return Book(
      count: data['count'] ?? 0,
      cover: BookCover.fromJSON(data['cover']),
      createdAt: Utilities.date.fromFirestore(data['createdAt']),
      description: data['description'] ?? '',
      id: data['id'] ?? '',
      illustrations: parseIllustrations(data['illustrations']),
      layout: parseLayout(data['layout']),
      layoutMobile: parseLayout(data['layoutMobile']),
      layoutOrientation: parseOrientation(data['layoutOrientation']),
      layoutOrientationMobile:
          parseOrientation(data['layoutOrientationMobile']),
      name: data['name'] ?? '',
      updatedAt: Utilities.date.fromFirestore(data['updatedAt']),
      urls: BookUrls.fromJSON(data['urls']),
      visibility: parseStringVisibility(data['visibility']),
    );
  }

  static List<BookIllustration> parseIllustrations(data) {
    final illustrations = <BookIllustration>[];

    if (data == null) {
      return illustrations;
    }

    for (var bookIllustrationData in data) {
      illustrations.add(BookIllustration.fromJSON(bookIllustrationData));
    }

    return illustrations;
  }

  /// Return this book cover url.
  /// It can either be custom (manually set),
  /// auto (set to the last uploaded illustration),
  /// or default if the book is empty.
  String getCoverUrl() {
    String url = "https://firebasestorage.googleapis.com/"
        "v0/b/artbooking-54d22.appspot.com/o/static"
        "%2Fimages%2Fbook_cover_512x683.png"
        "?alt=media&token=d77bc23b-90d7-4663-be3a-e878c6403e51";

    if (cover.custom.url.isNotEmpty) {
      url = cover.custom.url;
    } else if (cover.auto.url.isNotEmpty) {
      url = cover.auto.url;
    }

    return url;
  }

  String layoutOrientationToString({bool isMobile = false}) {
    final layoutOrientationValue =
        isMobile ? layoutOrientationMobile : layoutOrientation;

    switch (layoutOrientationValue) {
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

  String layoutToString({bool mobile = false}) {
    final layoutValue = mobile ? layoutMobile : layout;

    switch (layoutValue) {
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
      case 'both':
        return EnumBookLayoutOrientation.both;
      case 'horizontal':
        return EnumBookLayoutOrientation.horizontal;
      case 'vertical':
        return EnumBookLayoutOrientation.vertical;
      default:
        return EnumBookLayoutOrientation.vertical;
    }
  }

  static EnumContentVisibility parseStringVisibility(String? stringVisibility) {
    switch (stringVisibility) {
      case 'acl':
        return EnumContentVisibility.acl;
      case 'private':
        return EnumContentVisibility.private;
      case 'public':
        return EnumContentVisibility.public;
      default:
        return EnumContentVisibility.private;
    }
  }

  String visibilityToString() {
    switch (visibility) {
      case EnumContentVisibility.acl:
        return 'acl';
      case EnumContentVisibility.private:
        return 'private';
      case EnumContentVisibility.public:
        return 'public';
      default:
        return 'private';
    }
  }
}
