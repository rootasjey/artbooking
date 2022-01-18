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
import 'package:artbooking/types/license/license_from.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = '/dashboard/*';

  @override
  List<String> get pathPatterns => [route];

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
        title: "Dashboard",
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}

class DashboardLocationContent extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = '/dashboard';

  /// Books route value for this location.
  static const String booksRoute = '/dashboard/books';

  /// Illustrations route value for this location.
  static const String illustrationsRoute = '/dashboard/illustrations';

  /// Profile route value for this location.
  static const String profileRoute = '/dashboard/profile';

  /// Profile route value for this location.
  static const String editProfilePictureRoute = '/dashboard/profile/edit/pp';

  /// Settings route value for this location.
  static const String settingsRoute = '/dashboard/settings';

  /// Delete account route value for this location.
  static const String deleteAccountRoute = '/dashboard/settings/delete/account';

  /// Statistics route value for this location.
  static const String statisticsRoute = '/dashboard/statistics';

  /// Update email route value for this location.
  static const String updateEmailRoute = '/dashboard/settings/update/email';

  /// Update password route value for this location.
  static const String updatePasswordRoute =
      '/dashboard/settings/update/password';

  /// Update username route value for this location.
  static const String updateUsernameRoute =
      '/dashboard/settings/update/username';

  static const String licensesRoute = '$route/licenses';
  static const String licenseRoute = '$licensesRoute/:licenseId';

  @override
  List<String> get pathPatterns => [
        booksRoute,
        '$booksRoute/:bookId',
        // -> '/dashboard/books/:bookId',
        illustrationsRoute,
        '$illustrationsRoute/:illustrationId',
        // -> '/dashboard/illustrations/:illustrationId',
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
        title: "dashboard".tr(),
        type: BeamPageType.fadeTransition,
      ),
      if (state.pathPatternSegments.contains('statistics'))
        BeamPage(
          child: ActivityPage(),
          key: ValueKey(statisticsRoute),
          title: "statistics".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains('books'))
        BeamPage(
          child: MyBooksPage(),
          key: ValueKey(booksRoute),
          title: "My Books",
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(':bookId'))
        BeamPage(
          child: DashboardPageBook(
            bookId: state.pathParameters['bookId']!,
          ),
          key: ValueKey('$booksRoute/one'),
          title: "Book",
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains('illustrations'))
        BeamPage(
          child: MyIllustrationsPage(),
          key: ValueKey(illustrationsRoute),
          title: "My Illustrations",
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(':illustrationId'))
        BeamPage(
          child: IllustrationPage(
            illustrationId: state.pathParameters['illustrationId']!,
          ),
          key: ValueKey('$illustrationsRoute/one'),
          title: "Illustration",
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains('settings'))
        BeamPage(
          child: SettingsPage(),
          key: ValueKey('$settingsRoute'),
          title: "Settings",
          type: BeamPageType.fadeTransition,
        ),
      if (isDeleteAccount(state.pathPatternSegments))
        BeamPage(
          child: SettingsPageDeleteAccount(),
          key: ValueKey('$deleteAccountRoute'),
          title: "Delete account",
          type: BeamPageType.fadeTransition,
        ),
      if (isUpdateEmail(state.pathPatternSegments))
        BeamPage(
          child: SettingsPageUpdateEmail(),
          key: ValueKey('$updateEmailRoute'),
          title: "Update email",
          type: BeamPageType.fadeTransition,
        ),
      if (isUpdatePassword(state.pathPatternSegments))
        BeamPage(
          child: SettingsPageUpdatePassword(),
          key: ValueKey('$updatePasswordRoute'),
          title: "Update password",
          type: BeamPageType.fadeTransition,
        ),
      if (isUpdateUsername(state.pathPatternSegments))
        BeamPage(
          child: SettingsPageUpdateUsername(),
          key: ValueKey('$updateUsernameRoute'),
          title: "Update username",
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains('profile'))
        BeamPage(
          child: DashboardPageProfile(),
          key: ValueKey('$editProfilePictureRoute'),
          title: "My Profile",
          type: BeamPageType.fadeTransition,
        ),
      if (isEditPictureProfile(state.pathPatternSegments))
        BeamPage(
          child: EditIllustrationPageImage(),
          key: ValueKey('$editProfilePictureRoute'),
          title: "Edit Profile Picture",
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains('licenses'))
        BeamPage(
          child: LicensesPage(),
          key: ValueKey('$licensesRoute'),
          title: 'Licenses',
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(':licenseId'))
        BeamPage(
          child: LicensePage(
            from: getLicenseFrom(state.routeState),
            licenseId: state.pathParameters['licenseId'] ?? '',
          ),
          key: ValueKey('$licenseRoute'),
          title: 'License',
          type: BeamPageType.fadeTransition,
        ),
    ];
  }

  LicenseFrom getLicenseFrom(Object? routeState) {
    final mapState = routeState as Map<String, dynamic>;

    if (mapState['from'] == 'staff') {
      return LicenseFrom.staff;
    }

    return LicenseFrom.user;
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
