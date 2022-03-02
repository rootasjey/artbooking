import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/screens/atelier/atelier_page_card.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class AtelierPageWelcome extends ConsumerWidget {
  const AtelierPageWelcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(AppState.userProvider);
    final userFirestore = userState.firestoreUser;

    String name = 'Anonymous';

    if (userFirestore != null) {
      name = userFirestore.name.isNotEmpty
          ? userFirestore.name
          : userFirestore.email;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          ApplicationBar(minimal: true),
          header(),
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              Padding(
                padding: const EdgeInsets.only(left: 54.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    greetings(
                      color: Theme.of(context).primaryColor,
                      name: name,
                    ),
                    navigationDescription(),
                    sectionsList(context),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget header() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 54.0,
        bottom: 54.0,
      ),
      sliver: PageTitle(
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
            style: Utilities.fonts.style(
              color: color,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      style: Utilities.fonts.style(
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
        style: Utilities.fonts.style(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget sectionsList(BuildContext context) {
    int index = 0;

    final List<Widget> children = [
      AtelierPageCard(
        hoverColor: Constants.colors.activity,
        iconData: UniconsLine.chart_pie,
        textTitle: "activity".tr(),
        textSubtitle: "activity_subtitle".tr(),
        onTap: () {
          context.beamToNamed(AtelierLocationContent.activityRoute);
        },
      ),
      AtelierPageCard(
        hoverColor: Constants.colors.illustrations,
        iconData: UniconsLine.picture,
        textTitle: "illustrations".tr(),
        textSubtitle: "illustrations_my_subtitle".tr(),
        onTap: () {
          context.beamToNamed(AtelierLocationContent.illustrationsRoute);
        },
      ),
      AtelierPageCard(
        hoverColor: Constants.colors.books,
        iconData: UniconsLine.book_alt,
        textTitle: "books".tr(),
        textSubtitle: "books_subtitle".tr(),
        onTap: () {
          context.beamToNamed(AtelierLocationContent.booksRoute);
        },
      ),
      AtelierPageCard(
        hoverColor: Constants.colors.settings,
        iconData: UniconsLine.setting,
        textTitle: "settings".tr(),
        textSubtitle: "settings_subtitle".tr(),
        onTap: () {
          context.beamToNamed(AtelierLocationContent.settingsRoute);
        },
      ),
      AtelierPageCard(
        hoverColor: Constants.colors.profile,
        iconData: UniconsLine.user,
        textTitle: "profile".tr(),
        textSubtitle: "profile_subtitle".tr(),
        onTap: () {
          context.beamToNamed(AtelierLocationContent.profileRoute);
        },
      ),
      AtelierPageCard(
        hoverColor: Constants.colors.likes,
        iconData: UniconsLine.heart,
        textTitle: "likes".tr(),
        textSubtitle: "likes_subtitle".tr(),
        onTap: () {
          context.beamToNamed(AtelierLocationContent.likesRoute);
        },
      ),
      AtelierPageCard(
        hoverColor: Constants.colors.licenses,
        iconData: UniconsLine.document_info,
        textTitle: "licenses".tr(),
        textSubtitle: "licenses_subtitle".tr(),
        onTap: () {
          context.beamToNamed(AtelierLocationContent.licensesRoute);
        },
      ),
      AtelierPageCard(
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

    return Padding(
      padding: const EdgeInsets.only(
        top: 32.0,
        bottom: 200.0,
      ),
      child: Wrap(
        spacing: 24.0,
        runSpacing: 24.0,
        children: children,
      ),
    );
  }
}