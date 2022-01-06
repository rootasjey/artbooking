import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book_cover.dart';
import 'package:artbooking/types/book_illustration.dart';
import 'package:artbooking/types/book_urls.dart';
import 'package:artbooking/types/enums.dart';

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
  BookLayout layout;

  /// Defines content layout and presentation for small screens.
  BookLayout layoutMobile;

  /// Defines layout scroll orientation.
  /// Will be used if [layout] value is {adaptativeGrid},
  /// {customGrid}, {customList}, {grid}, {smallGrid}, {largeGrid}.
  BookLayoutOrientation layoutOrientation;

  /// For small resolutions, defines layout scroll orientation.
  /// Will be used if [layout] value is {adaptativeGrid}, {customGrid},
  /// {customList}, {grid}, {smallGrid}, {largeGrid}.
  BookLayoutOrientation layoutOrientationMobile;

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
  final ContentVisibility visibility;

  Book({
    this.count = 0,
    required this.cover,
    this.createdAt,
    this.description = '',
    this.id = '',
    this.illustrations = const [],
    this.layout = BookLayout.grid,
    this.layoutMobile = BookLayout.verticalList,
    this.layoutOrientation = BookLayoutOrientation.vertical,
    this.layoutOrientationMobile = BookLayoutOrientation.vertical,
    this.matrice = const [[]],
    this.name = '',
    this.updatedAt,
    required this.urls,
    this.visibility = ContentVisibility.private,
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
      case BookLayoutOrientation.both:
        return 'both';
      case BookLayoutOrientation.horizontal:
        return 'horizontal';
      case BookLayoutOrientation.vertical:
        return 'vertical';
      default:
        return 'vertical';
    }
  }

  String layoutToString({bool mobile = false}) {
    final layoutValue = mobile ? layoutMobile : layout;

    switch (layoutValue) {
      case BookLayout.adaptativeGrid:
        return 'adaptativeGrid';
      case BookLayout.customExtendedGrid:
        return 'customExtendedGrid';
      case BookLayout.customGrid:
        return 'customGrid';
      case BookLayout.customList:
        return 'customList';
      case BookLayout.grid:
        return 'grid';
      case BookLayout.horizontalList:
        return 'horizontalList';
      case BookLayout.horizontalListWide:
        return 'horizontalListWide';
      case BookLayout.largeGrid:
        return 'largeGrid';
      case BookLayout.smallGrid:
        return 'smallGrid';
      case BookLayout.twoPagesBook:
        return 'twoPagesBook';
      case BookLayout.verticalList:
        return 'verticalList';
      case BookLayout.verticalListWide:
        return 'verticalListWide';
      default:
        return 'grid';
    }
  }

  static BookLayout parseLayout(String? stringLayout) {
    switch (stringLayout) {
      case 'adaptativeGrid':
        return BookLayout.adaptativeGrid;
      case 'customExtendedGrid':
        return BookLayout.customExtendedGrid;
      case 'customGrid':
        return BookLayout.customGrid;
      case 'horizontalList':
        return BookLayout.horizontalList;
      case 'horizontalListWide':
        return BookLayout.horizontalListWide;
      case 'grid':
        return BookLayout.grid;
      case 'largeGrid':
        return BookLayout.largeGrid;
      case 'smallGrid':
        return BookLayout.smallGrid;
      case 'twoPagesBook':
        return BookLayout.twoPagesBook;
      case 'verticalList':
        return BookLayout.verticalList;
      case 'verticalListWide':
        return BookLayout.verticalListWide;
      default:
        return BookLayout.adaptativeGrid;
    }
  }

  static BookLayoutOrientation parseOrientation(String? stringOrientation) {
    switch (stringOrientation) {
      case 'both':
        return BookLayoutOrientation.both;
      case 'horizontal':
        return BookLayoutOrientation.horizontal;
      case 'vertical':
        return BookLayoutOrientation.vertical;
      default:
        return BookLayoutOrientation.vertical;
    }
  }

  static ContentVisibility parseStringVisibility(String? stringVisibility) {
    switch (stringVisibility) {
      case 'acl':
        return ContentVisibility.acl;
      case 'private':
        return ContentVisibility.private;
      case 'public':
        return ContentVisibility.public;
      default:
        return ContentVisibility.private;
    }
  }

  String visibilityToString() {
    switch (visibility) {
      case ContentVisibility.acl:
        return 'acl';
      case ContentVisibility.private:
        return 'private';
      case ContentVisibility.public:
        return 'public';
      default:
        return 'private';
    }
  }
}
