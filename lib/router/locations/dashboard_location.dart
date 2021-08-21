import 'package:artbooking/router/locations/signin_location.dart';
import 'package:artbooking/screens/dashboard_welcome_page.dart';
import 'package:artbooking/screens/dashboard_page.dart';
import 'package:artbooking/screens/delete_account_page.dart';
import 'package:artbooking/screens/edit_image_page.dart';
import 'package:artbooking/screens/illustration_page.dart';
import 'package:artbooking/screens/my_book_page.dart';
import 'package:artbooking/screens/my_statistics_page.dart';
import 'package:artbooking/screens/my_books_page.dart';
import 'package:artbooking/screens/my_illustrations_page.dart';
import 'package:artbooking/screens/my_profile_page.dart';
import 'package:artbooking/screens/settings_page.dart';
import 'package:artbooking/screens/update_email_page.dart';
import 'package:artbooking/screens/update_password_page.dart';
import 'package:artbooking/screens/update_username_page.dart';
import 'package:artbooking/state/user.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

class DashboardLocation extends BeamLocation {
  /// Main root value for this location.
  static const String route = '/dashboard/*';

  @override
  List<String> get pathBlueprints => [route];

  /// Redirect to signin page ('/signin')
  /// if the user is not authenticated.
  @override
  List<BeamGuard> get guards => [
        BeamGuard(
          pathBlueprints: [route],
          check: (context, location) => stateUser.isUserConnected,
          beamToNamed: SigninLocation.route,
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

class DashboardContentLocation extends BeamLocation {
  DashboardContentLocation(BeamState state) : super(state);

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

  @override
  List<String> get pathBlueprints => [
        booksRoute,
        '$booksRoute/:bookId',
        // -> '/dashboard/books/:bookId',
        '$illustrationsRoute/:illustrationId',
        // -> '/dashboard/illustrations/:illustrationId',
        settingsRoute,
        deleteAccountRoute,
        updateEmailRoute,
        updatePasswordRoute,
        updateUsernameRoute,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: DashboardWelcomePage(),
        key: ValueKey(route),
        title: "dashboard".tr(),
        type: BeamPageType.fadeTransition,
      ),
      if (state.pathBlueprintSegments.contains('statistics'))
        BeamPage(
          child: MyActivityPage(),
          key: ValueKey(statisticsRoute),
          title: "statistics".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathBlueprintSegments.contains('books'))
        BeamPage(
          child: MyBooksPage(),
          key: ValueKey(booksRoute),
          title: "My Books",
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathBlueprintSegments.contains(':bookId'))
        BeamPage(
          child: MyBookPage(
            bookId: state.pathParameters['bookId']!,
          ),
          key: ValueKey('$booksRoute/one'),
          title: "Book",
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathBlueprintSegments.contains('illustrations'))
        BeamPage(
          child: MyIllustrationsPage(),
          key: ValueKey(illustrationsRoute),
          title: "My Illustrations",
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathBlueprintSegments.contains(':illustrationId'))
        BeamPage(
          child: IllustrationPage(
            illustrationId: state.pathParameters['illustrationId']!,
          ),
          key: ValueKey('$illustrationsRoute/one'),
          title: "Illustration",
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathBlueprintSegments.contains('settings'))
        BeamPage(
          child: SettingsPage(),
          key: ValueKey('$settingsRoute'),
          title: "Settings",
          type: BeamPageType.fadeTransition,
        ),
      if (isDeleteAccount(state.pathBlueprintSegments))
        BeamPage(
          child: DeleteAccountPage(),
          key: ValueKey('$deleteAccountRoute'),
          title: "Delete account",
          type: BeamPageType.fadeTransition,
        ),
      if (isUpdateEmail(state.pathBlueprintSegments))
        BeamPage(
          child: UpdateEmailPage(),
          key: ValueKey('$updateEmailRoute'),
          title: "Update email",
          type: BeamPageType.fadeTransition,
        ),
      if (isUpdatePassword(state.pathBlueprintSegments))
        BeamPage(
          child: UpdatePasswordPage(),
          key: ValueKey('$updatePasswordRoute'),
          title: "Update password",
          type: BeamPageType.fadeTransition,
        ),
      if (isUpdateUsername(state.pathBlueprintSegments))
        BeamPage(
          child: UpdateUsernamePage(),
          key: ValueKey('$updateUsernameRoute'),
          title: "Update username",
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathBlueprintSegments.contains('profile'))
        BeamPage(
          child: MyProfilePage(),
          key: ValueKey('$editProfilePictureRoute'),
          title: "My Profile",
          type: BeamPageType.fadeTransition,
        ),
      if (isEditPictureProfile(state.pathBlueprintSegments))
        BeamPage(
          child: EditImagePage(),
          key: ValueKey('$editProfilePictureRoute'),
          title: "Edit Profile Picture",
          type: BeamPageType.fadeTransition,
        ),
    ];
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
