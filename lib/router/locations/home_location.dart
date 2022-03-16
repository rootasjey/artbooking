import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/profile/profile_page.dart';
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
  static const String route = "/";
  static const String illustrationsRoute = "/illustrations";
  static const String illustrationRoute = "$illustrationsRoute/:illustrationId";
  static const String booksRoute = "/books";
  static const String bookRoute = "$booksRoute/:bookId";
  static const String userProfileRoute = "/users/:userId";
  static const String illustrationBookRoute = "$bookRoute/:illustrationId/";

  @override
  List<String> get pathPatterns => [
        route,
        illustrationsRoute,
        illustrationRoute,
        booksRoute,
        bookRoute,
        illustrationBookRoute,
        userProfileRoute,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: HomePage(),
        key: ValueKey(route),
        title: Utilities.ui.getPageTitle("home".tr()),
        type: BeamPageType.fadeTransition,
      ),
      if (state.pathPatternSegments.contains("books"))
        BeamPage(
          child: BooksPage(),
          key: ValueKey(booksRoute),
          title: Utilities.ui.getPageTitle("books".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(":bookId"))
        BeamPage(
          child: BookPage(
            bookId: state.pathParameters["bookId"]!,
          ),
          key: ValueKey(bookRoute),
          title: Utilities.ui.getPageTitle("book".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("illustrations"))
        BeamPage(
          child: IllustrationsPage(),
          key: ValueKey(illustrationsRoute),
          title: Utilities.ui.getPageTitle("illustrations".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(":illustrationId"))
        BeamPage(
          child: IllustrationPage(
            illustrationId: state.pathParameters["illustrationId"]!,
            heroTag: Utilities.navigation.getHeroTag(state.routeState),
          ),
          key: ValueKey(illustrationRoute),
          title: Utilities.ui.getPageTitle("illustration".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("users") &&
          state.pathPatternSegments.contains(":userId"))
        BeamPage(
          child: ProfilePage(
            userId: state.pathParameters["userId"] ?? '',
          ),
          key: ValueKey("$userProfileRoute"),
          title: Utilities.ui.getPageTitle("profile".tr()),
          type: BeamPageType.fadeTransition,
        ),
    ];
  }
}
