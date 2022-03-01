import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/signin_location.dart';
import 'package:artbooking/screens/atelier/atelier_page_welcome.dart';
import 'package:artbooking/screens/atelier/atelier_page.dart';
import 'package:artbooking/screens/atelier/profile/profile_page.dart';
import 'package:artbooking/screens/likes/likes_page.dart';
import 'package:artbooking/screens/settings/delete_account/delete_account_page.dart';
import 'package:artbooking/screens/illustrations/illustration_page.dart';
import 'package:artbooking/screens/licenses/one/license_page.dart';
import 'package:artbooking/screens/licenses/many/licenses_page.dart';
import 'package:artbooking/screens/book/book_page.dart';
import 'package:artbooking/screens/activity/activity_page.dart';
import 'package:artbooking/screens/atelier/books/my_books_page.dart';
import 'package:artbooking/screens/atelier/illustrations/my_illustrations_page.dart';
import 'package:artbooking/screens/settings/settings_page.dart';
import 'package:artbooking/screens/settings/update_email/update_email_page.dart';
import 'package:artbooking/screens/settings/update_password/update_password_page.dart';
import 'package:artbooking/screens/settings/update_username/update_username_page.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AtelierLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/atelier";
  static const String routeWildCard = "/atelier/*";

  @override
  List<String> get pathPatterns => [routeWildCard];

  /// Redirect to signin page ('/signin') if the user is not authenticated.
  @override
  List<BeamGuard> get guards => [
        BeamGuard(
          pathPatterns: [route],
          check: (context, location) {
            final providerContainer = ProviderScope.containerOf(
              context,
              listen: false,
            );

            final isAuthenticated = providerContainer
                .read(AppState.userProvider.notifier)
                .isAuthenticated;

            return isAuthenticated;
          },
          beamToNamed: (origin, target) => SigninLocation.route,
        ),
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: AtelierPage(),
        key: ValueKey(route),
        title: Utilities.getPageTitle("atelier".tr()),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}

class AtelierLocationContent extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/atelier";

  /// Activity route value for this location.
  static const String activityRoute = "$route/activity";

  /// Books route value for this location.
  static const String booksRoute = "$route/books";

  /// Book route value for this location.
  static const String bookRoute = "$booksRoute/:bookId";

  /// Illustrations route value for this location.
  static const String illustrationsRoute = "$route/illustrations";

  /// Illustration route value for this location.
  static const String illustrationRoute = "$illustrationsRoute/:illustrationId";

  static const String illustrationBookRoute = "$bookRoute/:illustrationId/";

  static const String licensesRoute = "$route/licenses";
  static const String licenseRoute = "$licensesRoute/:licenseId";

  static const String likesRoute = "$route/likes";

  /// Profile route value for this location.
  static const String profileRoute = "$route/profile";

  /// Settings route value for this location.
  static const String settingsRoute = "$route/settings";

  /// Delete account route value for this location.
  static const String deleteAccountRoute = "$settingsRoute/delete/account";

  /// Update email route value for this location.
  static const String updateEmailRoute = "$settingsRoute/update/email";

  /// Update password route value for this location.
  static const String updatePasswordRoute = "$settingsRoute/update/password";

  /// Update username route value for this location.
  static const String updateUsernameRoute = "$settingsRoute/update/username";

  @override
  List<String> get pathPatterns => [
        booksRoute,
        bookRoute,
        illustrationsRoute,
        illustrationRoute,
        illustrationBookRoute,
        activityRoute,
        profileRoute,
        settingsRoute,
        deleteAccountRoute,
        updateEmailRoute,
        updatePasswordRoute,
        updateUsernameRoute,
        licensesRoute,
        licenseRoute,
        likesRoute,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: AtelierPageWelcome(),
        key: ValueKey(route),
        title: Utilities.getPageTitle("atelier".tr()),
        type: BeamPageType.fadeTransition,
      ),
      if (state.pathPatternSegments.contains("activity"))
        BeamPage(
          child: ActivityPage(),
          key: ValueKey(activityRoute),
          title: Utilities.getPageTitle("activity".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("books"))
        BeamPage(
          child: MyBooksPage(),
          key: ValueKey(booksRoute),
          title: Utilities.getPageTitle("books_my".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(":bookId"))
        BeamPage(
          child: BookPage(
            bookId: state.pathParameters["bookId"]!,
          ),
          key: ValueKey("$booksRoute/one"),
          title: Utilities.getPageTitle("book".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("illustrations"))
        BeamPage(
          child: MyIllustrationsPage(),
          key: ValueKey(illustrationsRoute),
          title: Utilities.getPageTitle("illustrations_my".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(":illustrationId"))
        BeamPage(
          child: IllustrationPage(
            illustrationId: state.pathParameters["illustrationId"]!,
          ),
          key: ValueKey("$illustrationsRoute/one"),
          title: Utilities.getPageTitle("illustration".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("settings"))
        BeamPage(
          child: SettingsPage(),
          key: ValueKey("$settingsRoute"),
          title: Utilities.getPageTitle("settings".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isDeleteAccount(state.pathPatternSegments))
        BeamPage(
          child: SettingsPageDeleteAccount(),
          key: ValueKey("$deleteAccountRoute"),
          title: Utilities.getPageTitle("account_delete".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isUpdateEmail(state.pathPatternSegments))
        BeamPage(
          child: UpdateEmailPage(),
          key: ValueKey("$updateEmailRoute"),
          title: Utilities.getPageTitle("email_update".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isUpdatePassword(state.pathPatternSegments))
        BeamPage(
          child: UpdatePasswordPage(),
          key: ValueKey("$updatePasswordRoute"),
          title: Utilities.getPageTitle("password_update".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isUpdateUsername(state.pathPatternSegments))
        BeamPage(
          child: UpdateUsernamePage(),
          key: ValueKey("$updateUsernameRoute"),
          title: Utilities.getPageTitle("username_update".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("profile"))
        BeamPage(
          child: ProfilePage(
            userId: state.pathParameters["userId"] ?? '',
          ),
          key: ValueKey("$profileRoute"),
          title: Utilities.getPageTitle("profile_my".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("licenses"))
        BeamPage(
          child: LicensesPage(),
          key: ValueKey("$licensesRoute"),
          title: Utilities.getPageTitle("licenses".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(":licenseId"))
        BeamPage(
          child: LicensePage(
            type: getLicenseType(state.routeState),
            licenseId: state.pathParameters["licenseId"] ?? '',
          ),
          key: ValueKey("$licenseRoute"),
          title: Utilities.getPageTitle("license".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("likes"))
        BeamPage(
          child: LikesPage(),
          key: ValueKey("$likesRoute"),
          title: Utilities.getPageTitle("likes".tr()),
          type: BeamPageType.fadeTransition,
        ),
    ];
  }

  EnumLicenseType getLicenseType(Object? routeState) {
    final mapState = routeState as Map<String, dynamic>;

    if (mapState["type"] == "staff") {
      return EnumLicenseType.staff;
    }

    return EnumLicenseType.user;
  }

  /// True if the path match the delete account page.
  bool isDeleteAccount(List<String> pathBlueprintSegments) {
    return pathBlueprintSegments.contains("delete") &&
        pathBlueprintSegments.contains("account");
  }

  /// True if the path match the delete account page.
  bool isUpdateEmail(List<String> pathBlueprintSegments) {
    return pathBlueprintSegments.contains("update") &&
        pathBlueprintSegments.contains("email");
  }

  /// True if the path match the delete account page.
  bool isUpdatePassword(List<String> pathBlueprintSegments) {
    return pathBlueprintSegments.contains("update") &&
        pathBlueprintSegments.contains("password");
  }

  /// True if the path match the delete account page.
  bool isUpdateUsername(List<String> pathBlueprintSegments) {
    return pathBlueprintSegments.contains("update") &&
        pathBlueprintSegments.contains("username");
  }
}
