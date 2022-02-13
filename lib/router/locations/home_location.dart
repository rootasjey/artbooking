import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/book/book_page.dart';
import 'package:artbooking/screens/book/books_page.dart';
import 'package:artbooking/screens/home/home_page.dart';
import 'package:artbooking/screens/illustrations/illustration_page.dart';
import 'package:artbooking/screens/illustrations/illustrations_page.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/widgets.dart';

class HomeLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = '/';
  static const String illustrationsRoute = '/illustrations';
  static const String illustrationRoute = '/illustrations/:illustrationId';
  static const String booksRoute = '/books';
  static const String bookRoute = '/books/:bookId';

  @override
  List<String> get pathPatterns => [
        route,
        illustrationsRoute,
        illustrationRoute,
        booksRoute,
        bookRoute,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: HomePage(),
        key: ValueKey(route),
        title: Utilities.getPageTitle("home".tr()),
        type: BeamPageType.fadeTransition,
      ),
      if (state.pathPatternSegments.contains("illustrations"))
        BeamPage(
          child: IllustrationsPage(),
          key: ValueKey(illustrationsRoute),
          title: Utilities.getPageTitle("illustrations".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(":illustrationId"))
        BeamPage(
          child: IllustrationPage(
            illustrationId: state.pathParameters["illustrationId"]!,
          ),
          key: ValueKey(illustrationRoute),
          title: Utilities.getPageTitle("illustration".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("books"))
        BeamPage(
          child: BooksPage(),
          key: ValueKey(booksRoute),
          title: Utilities.getPageTitle("books".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(":bookId"))
        BeamPage(
          child: BookPage(
            bookId: state.pathParameters["bookId"]!,
          ),
          key: ValueKey(bookRoute),
          title: Utilities.getPageTitle("book".tr()),
          type: BeamPageType.fadeTransition,
        ),
    ];
  }
}
