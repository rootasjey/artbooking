import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/signin_location.dart';
import 'package:artbooking/screens/atelier/atelier_page_welcome.dart';
import 'package:artbooking/screens/atelier/atelier_page.dart';
import 'package:artbooking/screens/atelier/profile/profile_page.dart';
import 'package:artbooking/screens/atelier/review/review_page.dart';
import 'package:artbooking/screens/likes/likes_page.dart';
import 'package:artbooking/screens/post_page.dart';
import 'package:artbooking/screens/posts/many/posts_page.dart';
import 'package:artbooking/screens/sections/edit/edit_section_page.dart';
import 'package:artbooking/screens/sections/many/sections_page.dart';
import 'package:artbooking/screens/sections/one/section_page.dart';
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
import 'package:artbooking/types/json_types.dart';
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
          pathPatterns: [route, routeWildCard],
          check: (context, location) {
            final ProviderContainer providerContainer =
                ProviderScope.containerOf(
              context,
              listen: false,
            );

            final bool isAuthenticated = providerContainer
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
        title: Utilities.ui.getPageTitle("atelier".tr()),
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

  static const String postsRoute = "$route/posts";
  static const String postRoute = "$postsRoute/:postId";

  /// Profile route value for this location.
  static const String profileRoute = "$route/profile";

  /// A specific route for books
  /// belonging to a profile page. This route existence
  /// allow to keep scroll state & assure hero transition.
  static const String profileBookRoute = "$profileRoute/b/:bookId";

  /// A specific route for illustration inside a book,
  /// belonging to a profile page. This route existence
  /// allow to keep scroll state & assure hero transition.
  static const String profileIllustrationBookRoute =
      "$profileBookRoute/i/:illustrationId";

  /// A specific route for illustrations
  /// belonging to a profile page. This route existence
  /// allow to keep scroll state & assure hero transition.
  static const String profileIllustrationRoute =
      "$profileRoute/i/:illustrationId";

  /// Staff route to review & approve books & illustrations
  /// to be display in public spaces (according to EULA).
  static const String reviewRoute = "$route/review";

  /// Settings route value for this location.
  static const String settingsRoute = "$route/settings";

  /// (admin) Sections route.
  static const String sectionsRoute = "$route/sections";

  /// (admin) Add a new section route.
  static const String addSectionRoute = "$sectionsRoute/add";

  /// (admin) Edit an existing section route.
  static const String editSectionRoute = "$sectionsRoute/:sectionId/edit";

  /// Single section route.
  static const String sectionRoute = "$sectionsRoute/:sectionId";

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
        sectionsRoute,
        addSectionRoute,
        sectionRoute,
        settingsRoute,
        deleteAccountRoute,
        updateEmailRoute,
        updatePasswordRoute,
        updateUsernameRoute,
        licensesRoute,
        licenseRoute,
        likesRoute,
        profileIllustrationRoute,
        profileBookRoute,
        profileIllustrationBookRoute,
        reviewRoute,
        postsRoute,
        postRoute,
        editSectionRoute,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: AtelierPageWelcome(),
        key: ValueKey(route),
        title: Utilities.ui.getPageTitle("atelier".tr()),
        type: BeamPageType.fadeTransition,
      ),
      if (state.pathPatternSegments.contains("activity"))
        BeamPage(
          child: ActivityPage(),
          key: ValueKey(activityRoute),
          title: Utilities.ui.getPageTitle("activity".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("profile"))
        BeamPage(
          child: ProfilePage(
            userId: state.pathParameters["userId"] ?? "",
          ),
          key: ValueKey("$profileRoute"),
          title: Utilities.ui.getPageTitle("profile".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("books"))
        BeamPage(
          child: MyBooksPage(),
          key: ValueKey(booksRoute),
          title: Utilities.ui.getPageTitle("books_my".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(":bookId"))
        BeamPage(
          child: BookPage(
            bookId: state.pathParameters["bookId"] ?? "",
            heroTag: Utilities.navigation.getHeroTag(state.routeState),
          ),
          key: ValueKey("$booksRoute/one"),
          title: Utilities.ui.getPageTitle("book".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("illustrations"))
        BeamPage(
          child: MyIllustrationsPage(),
          key: ValueKey(illustrationsRoute),
          title: Utilities.ui.getPageTitle("illustrations_my".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(":illustrationId"))
        BeamPage(
          child: IllustrationPage(
            illustrationId: state.pathParameters["illustrationId"]!,
            heroTag: Utilities.navigation.getHeroTag(state.routeState),
          ),
          key: ValueKey("$illustrationsRoute/one"),
          title: Utilities.ui.getPageTitle("illustration".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("settings"))
        BeamPage(
          child: SettingsPage(),
          key: ValueKey("$settingsRoute"),
          title: Utilities.ui.getPageTitle("settings".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isDeleteAccount(state.pathPatternSegments))
        BeamPage(
          child: SettingsPageDeleteAccount(),
          key: ValueKey("$deleteAccountRoute"),
          title: Utilities.ui.getPageTitle("account_delete".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isUpdateEmail(state.pathPatternSegments))
        BeamPage(
          child: UpdateEmailPage(),
          key: ValueKey("$updateEmailRoute"),
          title: Utilities.ui.getPageTitle("email_update".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isUpdatePassword(state.pathPatternSegments))
        BeamPage(
          child: UpdatePasswordPage(),
          key: ValueKey("$updatePasswordRoute"),
          title: Utilities.ui.getPageTitle("password_update".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isUpdateUsername(state.pathPatternSegments))
        BeamPage(
          child: UpdateUsernamePage(),
          key: ValueKey("$updateUsernameRoute"),
          title: Utilities.ui.getPageTitle("username_update".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("licenses"))
        BeamPage(
          child: LicensesPage(),
          key: ValueKey("$licensesRoute"),
          title: Utilities.ui.getPageTitle("licenses".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(":licenseId"))
        BeamPage(
          child: LicensePage(
            type: getLicenseType(state.routeState),
            licenseId: state.pathParameters["licenseId"] ?? "",
          ),
          key: ValueKey("$licenseRoute"),
          title: Utilities.ui.getPageTitle("license".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("likes"))
        BeamPage(
          child: LikesPage(),
          key: ValueKey("$likesRoute"),
          title: Utilities.ui.getPageTitle("likes".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("sections"))
        BeamPage(
          child: SectionsPage(),
          key: ValueKey("$sectionsRoute"),
          title: Utilities.ui.getPageTitle("sections".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isSectionPage(state))
        BeamPage(
          child: SectionPage(
            sectionId: state.pathParameters["sectionId"] ?? "",
          ),
          key: ValueKey("$sectionRoute"),
          title: Utilities.ui.getPageTitle("section".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isAddSection(state))
        BeamPage(
          child: EditSectionPage(
            sectionId: "",
          ),
          key: ValueKey("$addSectionRoute"),
          title: Utilities.ui.getPageTitle("sections".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (isEditSection(state))
        BeamPage(
          child: EditSectionPage(
            sectionId: state.pathParameters["sectionId"] ?? "",
          ),
          key: ValueKey("$editSectionRoute"),
          title: Utilities.ui.getPageTitle("sections".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("review"))
        BeamPage(
          child: ReviewPage(),
          key: ValueKey("$reviewRoute"),
          title: Utilities.ui.getPageTitle("review".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("posts"))
        BeamPage(
          child: PostsPage(),
          key: ValueKey("$postsRoute"),
          title: Utilities.ui.getPageTitle("posts".tr()),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(":postId"))
        BeamPage(
          child: PostPage(
            postId: state.pathParameters["postId"] ?? "",
          ),
          key: ValueKey("$postRoute"),
          title: Utilities.ui.getPageTitle("post".tr()),
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

  bool isAddSection(BeamState state) {
    return state.pathPatternSegments.contains("sections") &&
        state.pathPatternSegments.contains("add");
  }

  bool isEditSection(BeamState state) {
    return state.pathPatternSegments.contains("sections") &&
        state.pathPatternSegments.contains("edit") &&
        state.pathPatternSegments.contains(":sectionId");
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

  bool isSectionPage(BeamState state) {
    final bool containsSectionId =
        state.pathPatternSegments.contains(":sectionId");

    if (state.routeState == null) {
      return containsSectionId;
    }

    final Json? routeState = state.routeState as Json?;
    return routeState?["skip_route:SectionPage"] ?? containsSectionId;
  }
}
