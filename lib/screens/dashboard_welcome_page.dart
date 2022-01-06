import 'package:artbooking/components/main_app_bar/main_app_bar.dart';
import 'package:artbooking/components/section_card.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/types/globals/globals.dart';
import 'package:artbooking/types/globals/app_state.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class DashboardWelcomePage extends ConsumerWidget {
  const DashboardWelcomePage({Key? key}) : super(key: key);

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
          SliverEdgePadding(),
          MainAppBar(),
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
                    placeDescription(),
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
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "dashboard".tr().toUpperCase(),
                style: FontsUtils.mainStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ]),
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
            style: FontsUtils.mainStyle(
              color: color,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      style: FontsUtils.mainStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget placeDescription() {
    return Opacity(
      opacity: 0.4,
      child: Text(
        "dashboard_sections_navigation".tr(),
        style: FontsUtils.mainStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget sectionsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 32.0,
        bottom: 200.0,
      ),
      child: Wrap(
        spacing: 24.0,
        runSpacing: 24.0,
        children: [
          SectionCard(
            hoverColor: Globals.constants.colors.activity,
            iconData: UniconsLine.chart_pie,
            textTitle: "statistics".tr(),
            textSubtitle: "statistics_subtitle".tr(),
            onTap: () {
              context.beamToNamed(DashboardLocationContent.statisticsRoute);
            },
          ),
          SectionCard(
            hoverColor: Globals.constants.colors.illustrations,
            iconData: UniconsLine.picture,
            textTitle: "illustrations".tr(),
            textSubtitle: "illustrations_subtitle".tr(),
            onTap: () {
              context.beamToNamed(DashboardLocationContent.illustrationsRoute);
            },
          ),
          SectionCard(
            hoverColor: Globals.constants.colors.books,
            iconData: UniconsLine.book_alt,
            textTitle: "books".tr(),
            textSubtitle: "books_subtitle".tr(),
            onTap: () {
              context.beamToNamed(DashboardLocationContent.booksRoute);
            },
          ),
          SectionCard(
            hoverColor: Globals.constants.colors.settings,
            iconData: UniconsLine.setting,
            textTitle: "settings".tr(),
            textSubtitle: "settings_subtitle".tr(),
            onTap: () {
              context.beamToNamed(DashboardLocationContent.settingsRoute);
            },
          ),
        ],
      ),
    );
  }
}
