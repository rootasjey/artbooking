import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

class NavigationUtilities {
  const NavigationUtilities();

  void back(BuildContext context) {
    if (Beamer.of(context).canBeamBack) {
      Beamer.of(context).beamBack();
      return;
    }

    Beamer.of(context).popRoute();
  }

  /// Return hero tag stored as a string from `routeState` map if any.
  String getHeroTag(Object? routeState) {
    if (routeState == null) {
      return "";
    }

    final mapState = routeState as Map<String, dynamic>;
    return mapState["heroTag"] ?? "";
  }

  String getProfileToBookRoute(BuildContext context, Book book, String userId) {
    final location = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .location;

    if (location == null) {
      return HomeLocation.profileBookRoute
          .replaceFirst(":userId", userId)
          .replaceFirst(":bookId", book.id);
    }

    if (location.contains("atelier")) {
      return AtelierLocationContent.profileBookRoute
          .replaceFirst(":bookId", book.id);
    }

    return HomeLocation.profileBookRoute
        .replaceFirst(":userId", userId)
        .replaceFirst(":bookId", book.id);
  }

  String getProfileToIllustrationRoute(
    BuildContext context,
    Illustration illustration,
    String userId,
  ) {
    final String? location = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .location;

    if (location == "/" || userId.isEmpty) {
      return HomeLocation.directIllustrationRoute.replaceFirst(
        ":illustrationId",
        illustration.id,
      );
    }

    if (location == null) {
      return HomeLocation.profileIllustrationRoute
          .replaceFirst(":userId", userId)
          .replaceFirst(":illustrationId", illustration.id);
    }

    if (location.contains("atelier")) {
      return AtelierLocationContent.profileIllustrationRoute
          .replaceFirst(":illustrationId", illustration.id);
    }

    return HomeLocation.profileIllustrationRoute
        .replaceFirst(":userId", userId)
        .replaceFirst(":illustrationId", illustration.id);
  }

  /// Navigate from a profile page to a book page.
  void profileToBook(
    BuildContext context, {
    required Book book,
    required String heroTag,
    required String userId,
  }) {
    final String route = getProfileToBookRoute(context, book, userId);

    NavigationStateHelper.book = book;
    Beamer.of(context).beamToNamed(
      route,
      data: {
        "userId": userId,
        "bookId": book.id,
      },
      routeState: {"heroTag": heroTag},
    );
  }

  /// Navigate from a profile page to an illustration page.
  void profileToIllustration(
    BuildContext context, {
    required Illustration illustration,
    required String heroTag,
    required String userId,
  }) {
    final String route = getProfileToIllustrationRoute(
      context,
      illustration,
      userId,
    );

    NavigationStateHelper.illustration = illustration;
    Beamer.of(context).beamToNamed(
      route,
      data: {
        "userId": userId,
        "illustrationId": illustration.id,
      },
      routeState: {"heroTag": heroTag},
    );
  }
}
