import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/signin_location.dart';
import 'package:artbooking/screens/dashboard/dashboard_page_welcome.dart';
import 'package:artbooking/screens/dashboard/dashboard_page.dart';
import 'package:artbooking/screens/settings/settings_page_delete_account.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page_image.dart';
import 'package:artbooking/screens/illustrations/illustration_page.dart';
import 'package:artbooking/screens/licenses/one/license_page.dart';
import 'package:artbooking/screens/licenses/many/licenses_page.dart';
import 'package:artbooking/screens/dashboard/dashboard_page_book.dart';
import 'package:artbooking/screens/activity/activity_page.dart';
import 'package:artbooking/screens/dashboard/dashboard_page_books.dart';
import 'package:artbooking/screens/dashboard/dashboard_page_illustrations.dart';
import 'package:artbooking/screens/dashboard/dashboard_page_profile.dart';
import 'package:artbooking/screens/settings/settings_page.dart';
import 'package:artbooking/screens/settings/settings_page_update_email.dart';
import 'package:artbooking/screens/settings/settings_page_update_password.dart';
import 'package:artbooking/screens/settings/settings_page_update_username.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = '/dashboard';
  static const String routeWildCard = '/dashboard/*';

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
        child: DashboardPage(),
        key: ValueKey(route),
        title: Utilities.getPageTitle("dashboard".tr()),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}

class DashboardLocationContent extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = '/dashboard';

  /// Books route value for this location.
  static const String booksRoute = '$route/books';

  /// Book route value for this location.
  static const String bookRoute = '$booksRoute/:bookId';

  /// Illustrations route value for this location.
  static const String illustrationsRoute = '$route/illustrations';

  /// Illustration route value for this location.
  static const String illustrationRoute = '$illustrationsRoute/:illustrationId';

  static const String illustrationBookRoute = '$bookRoute/:illustrationId/';

  /// Profile route value for this location.
  static const String profileRoute = '$route/profile';

  /// Profile route value for this location.
  static const String editProfilePictureRoute = '$route/profile/edit/pp';

  /// Settings route value for this location.
  static const String settingsRoute = '$route/settings';

  /// Delete account route value for this location.
  static const String deleteAccountRoute = '$route/settings/delete/account';

  /// Statistics route value for this location.
  static const String statisticsRoute = '$route/statistics';

  /// Update email route value for this location.
  static const String updateEmailRoute = '$route/settings/update/email';

  /// Update password route value for this location.
  static const String updatePasswordRoute = '$route/settings/update/password';

  /// Update username route value for this location.
  static const String updateUsernameRoute = '$route/settings/update/username';

  static const String licensesRoute = '$route/licenses';
  static const String licenseRoute = '$licensesRoute/:licenseId';

  @override
  List<String> get pathPatterns => [
        booksRoute,
        bookRoute,
        illustrationsRoute,
        illustrationRoute,
        illustrationBookRoute,
        statisticsRoute,
        profileRoute,
        settingsRoute,
        deleteAccountRoute,
        updateEmailRoute,
        updatePasswordRoute,
        updateUsernameRoute,
        editProfilePictureRoute,
        licensesRoute,
        licenseRoute,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: DashboardPageWelcome(),
        key: ValueKey(route),
        title: Utilities.getPageTitle("dashboard".tr()),
        type: BeamPageType.fadeTransition,
      ),
      if (state.pathPatternSegments.contains('statistics'))
        BeamPage(
          child: ActivityPage(),
          key: ValueKey(statisticsRoute),
          title: Utilities.getPageTitle("statistics".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains('books'))
        BeamPage(
          child: MyBooksPage(),
          key: ValueKey(booksRoute),
          title: Utilities.getPageTitle("books_my".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(':bookId'))
        BeamPage(
          child: DashboardPageBook(
            bookId: state.pathParameters['bookId']!,
          ),
          key: ValueKey('$booksRoute/one'),
          title: Utilities.getPageTitle("book".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains('illustrations'))
        BeamPage(
          child: MyIllustrationsPage(),
          key: ValueKey(illustrationsRoute),
          title: Utilities.getPageTitle("illustrations_my".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(':illustrationId'))
        BeamPage(
          child: IllustrationPage(
            illustrationId: state.pathParameters['illustrationId']!,
          ),
          key: ValueKey('$illustrationsRoute/one'),
          title: Utilities.getPageTitle("illustration".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains('settings'))
        BeamPage(
          child: SettingsPage(),
          key: ValueKey('$settingsRoute'),
          title: Utilities.getPageTitle("settings".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isDeleteAccount(state.pathPatternSegments))
        BeamPage(
          child: SettingsPageDeleteAccount(),
          key: ValueKey('$deleteAccountRoute'),
          title: Utilities.getPageTitle("account_delete".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isUpdateEmail(state.pathPatternSegments))
        BeamPage(
          child: SettingsPageUpdateEmail(),
          key: ValueKey('$updateEmailRoute'),
          title: Utilities.getPageTitle("email_update".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isUpdatePassword(state.pathPatternSegments))
        BeamPage(
          child: SettingsPageUpdatePassword(),
          key: ValueKey('$updatePasswordRoute'),
          title: Utilities.getPageTitle("password_update".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isUpdateUsername(state.pathPatternSegments))
        BeamPage(
          child: SettingsPageUpdateUsername(),
          key: ValueKey('$updateUsernameRoute'),
          title: Utilities.getPageTitle("username_update".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains('profile'))
        BeamPage(
          child: DashboardPageProfile(),
          key: ValueKey('$editProfilePictureRoute'),
          title: Utilities.getPageTitle("profile_my".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isEditPictureProfile(state.pathPatternSegments))
        BeamPage(
          child: EditIllustrationPageImage(),
          key: ValueKey('$editProfilePictureRoute'),
          title: Utilities.getPageTitle("profile_picture_edit".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains('licenses'))
        BeamPage(
          child: LicensesPage(),
          key: ValueKey('$licensesRoute'),
          title: Utilities.getPageTitle("licenses".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(':licenseId'))
        BeamPage(
          child: LicensePage(
            type: getLicenseType(state.routeState),
            licenseId: state.pathParameters['licenseId'] ?? '',
          ),
          key: ValueKey('$licenseRoute'),
          title: Utilities.getPageTitle("license".tr()),
          type: BeamPageType.fadeTransition,
        ),
    ];
  }

  EnumLicenseType getLicenseType(Object? routeState) {
    final mapState = routeState as Map<String, dynamic>;

    if (mapState['type'] == 'staff') {
      return EnumLicenseType.staff;
    }

    return EnumLicenseType.user;
  }

  /// True if the path match the delete account page.
  bool isDeleteAccount(List<String> pathBlueprintSegments) {
    return pathBlueprintSegments.contains('delete') &&
        pathBlueprintSegments.contains('account');
  }

  /// True if the path match the delete account page.
  bool isUpdateEmail(List<String> pathBlueprintSegments) {
    return pathBlueprintSegments.contains('update') &&
        pathBlueprintSegments.contains('email');
  }

  /// True if the path match the delete account page.
  bool isUpdatePassword(List<String> pathBlueprintSegments) {
    return pathBlueprintSegments.contains('update') &&
        pathBlueprintSegments.contains('password');
  }

  /// True if the path match the delete account page.
  bool isUpdateUsername(List<String> pathBlueprintSegments) {
    return pathBlueprintSegments.contains('update') &&
        pathBlueprintSegments.contains('username');
  }

  /// True if the path match the delete account page.
  bool isEditPictureProfile(List<String> pathBlueprintSegments) {
    return pathBlueprintSegments.contains('profile') &&
        pathBlueprintSegments.contains('edit') &&
        pathBlueprintSegments.contains('pp');
  }
}
