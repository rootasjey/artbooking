import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/screens/atelier/atelier_page_card.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/screens/connection/signin_page.dart';
import 'package:artbooking/types/user/user.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class AtelierPageWelcome extends ConsumerWidget {
  const AtelierPageWelcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User userState = ref.watch(AppState.userProvider);
    final UserFirestore? userFirestore = userState.firestoreUser;
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    String name = "Anonymous";

    if (userFirestore != null) {
      name = userFirestore.name.isNotEmpty
          ? userFirestore.name
          : userFirestore.email;
    }

    final bool isAuthenticated = userFirestore?.id.isNotEmpty ?? false;

    if (!isAuthenticated && isMobileSize) {
      return SigninPage(showBackButton: false);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          ApplicationBar(
            minimal: true,
          ),
          header(isMobileSize),
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              Padding(
                padding: isMobileSize
                    ? const EdgeInsets.symmetric(horizontal: 12.0)
                    : const EdgeInsets.only(left: 54.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    greetings(
                      color: Theme.of(context).primaryColor,
                      name: name,
                    ),
                    navigationDescription(),
                    sectionsList(
                      context,
                      userFirestore,
                      isMobileSize,
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget header(bool isMobileSize) {
    return SliverPadding(
      padding: EdgeInsets.only(
        top: 60.0,
        left: isMobileSize ? 12.0 : 54.0,
        bottom: isMobileSize ? 24 : 54.0,
      ),
      sliver: PageTitle(
        isMobileSize: isMobileSize,
        titleValue: "atelier".tr(),
        subtitleValue: "atelier_greetings".tr(),
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }

  Widget iconWithText({
    required Widget icon,
    required RichText richText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Opacity(
            opacity: 0.6,
            child: icon,
          ),
          richText,
        ],
      ),
    );
  }

  Widget greetings({required Color color, required String name}) {
    return Text.rich(
      TextSpan(
        text: "welcome".tr(),
        children: [
          TextSpan(
            text: " $name",
            style: Utilities.fonts.body(
              color: color,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      style: Utilities.fonts.body(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget navigationDescription() {
    return Opacity(
      opacity: 0.4,
      child: Text(
        "dashboard_sections_navigation".tr(),
        style: Utilities.fonts.body(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget sectionsList(
    BuildContext context,
    UserFirestore? userFirestore,
    bool isMobileSize,
  ) {
    int index = 0;

    bool canManageSections = false;
    bool canManageReviews = false;
    bool canManagePosts = false;

    if (userFirestore != null) {
      canManageSections = userFirestore.rights.canManageSections;
      canManageReviews = userFirestore.rights.canManageReviews;
      canManagePosts = userFirestore.rights.canManagePosts;
    }

    final List<Widget> children = [
      AtelierPageCard(
        noSizeConstraints: true,
        hoverColor: Constants.colors.activity,
        iconData: UniconsLine.chart_pie,
        textTitle: "activity".tr(),
        textSubtitle: "activity_subtitle".tr(),
        onTap: () {
          context.beamToNamed(AtelierLocationContent.activityRoute);
        },
      ),
      AtelierPageCard(
        noSizeConstraints: true,
        hoverColor: Constants.colors.illustrations,
        iconData: UniconsLine.picture,
        textTitle: "illustrations".tr(),
        textSubtitle: "illustrations_my_subtitle".tr(),
        onTap: () {
          context.beamToNamed(AtelierLocationContent.illustrationsRoute);
        },
      ),
      AtelierPageCard(
        noSizeConstraints: true,
        hoverColor: Constants.colors.books,
        iconData: UniconsLine.book_alt,
        textTitle: "books".tr(),
        textSubtitle: "books_subtitle".tr(),
        onTap: () {
          context.beamToNamed(AtelierLocationContent.booksRoute);
        },
      ),
      AtelierPageCard(
        noSizeConstraints: true,
        hoverColor: Constants.colors.settings,
        iconData: UniconsLine.setting,
        textTitle: "settings".tr(),
        textSubtitle: "settings_subtitle".tr(),
        onTap: () {
          context.beamToNamed(AtelierLocationContent.settingsRoute);
        },
      ),
      AtelierPageCard(
        noSizeConstraints: true,
        hoverColor: Constants.colors.profile,
        iconData: UniconsLine.user,
        textTitle: "profile".tr(),
        textSubtitle: "profile_subtitle".tr(),
        onTap: () {
          context.beamToNamed(
            AtelierLocationContent.profileRoute,
            routeState: {
              "userId": userFirestore?.id,
            },
          );
        },
      ),
      AtelierPageCard(
        noSizeConstraints: true,
        hoverColor: Constants.colors.likes,
        iconData: UniconsLine.heart,
        textTitle: "likes".tr(),
        textSubtitle: "likes_subtitle".tr(),
        onTap: () {
          context.beamToNamed(AtelierLocationContent.likesRoute);
        },
      ),
      AtelierPageCard(
        noSizeConstraints: true,
        hoverColor: Constants.colors.licenses,
        iconData: UniconsLine.document_info,
        textTitle: "licenses".tr(),
        textSubtitle: "licenses_subtitle".tr(),
        onTap: () {
          context.beamToNamed(AtelierLocationContent.licensesRoute);
        },
      ),
      if (canManageReviews)
        AtelierPageCard(
          noSizeConstraints: true,
          hoverColor: Constants.colors.review,
          iconData: UniconsLine.image_check,
          textTitle: "review".tr(),
          textSubtitle: "review_subtitle".tr(),
          onTap: () {
            context.beamToNamed(AtelierLocationContent.reviewRoute);
          },
        ),
      if (canManageSections)
        AtelierPageCard(
          noSizeConstraints: true,
          hoverColor: Constants.colors.sections,
          iconData: UniconsLine.web_grid,
          textTitle: "sections".tr(),
          textSubtitle: "sections_subtitle".tr(),
          onTap: () {
            context.beamToNamed(AtelierLocationContent.sectionsRoute);
          },
        ),
      if (canManagePosts)
        AtelierPageCard(
          noSizeConstraints: true,
          hoverColor: Constants.colors.sections,
          iconData: UniconsLine.file_edit_alt,
          textTitle: "posts".tr(),
          textSubtitle: "posts_presentation_subtitle".tr(),
          onTap: () {
            context.beamToNamed(AtelierLocationContent.postsRoute);
          },
        ),
      if (!isMobileSize)
        AtelierPageCard(
          noSizeConstraints: true,
          hoverColor: Constants.colors.home,
          iconData: UniconsLine.home,
          textTitle: "home".tr(),
          textSubtitle: "home_subtitle".tr(),
          onTap: () {
            Beamer.of(context, root: true).beamToNamed(HomeLocation.route);
          },
        ),
    ].map((child) {
      index++;

      return FadeInY(
        delay: Duration(milliseconds: index * 50),
        beginY: 32.0,
        child: child,
      );
    }).toList();

    if (isMobileSize) {
      return Container(
        // color: Colors.pink,
        padding: const EdgeInsets.only(
          top: 32.0,
          bottom: 200.0,
        ),
        child: Column(
          children: children,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 32.0,
        bottom: 200.0,
      ),
      child: Wrap(
        spacing: isMobileSize ? 4.0 : 24.0,
        runSpacing: isMobileSize ? 4.0 : 24.0,
        children: children,
      ),
    );
  }
}
