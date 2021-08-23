import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/components/section_card.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class DashboardWelcomePage extends StatelessWidget {
  const DashboardWelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverEdgePadding(),
          MainAppBar(),
          header(),
          body(context),
        ],
      ),
    );
  }

  Widget body(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.only(left: 54.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              greetings(),
              placeDescription(),
              sectionsList(context),
            ],
          ),
        ),
      ]),
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

  Widget greetings() {
    final username = stateUser.username ?? '';
    final email = stateUser.email;
    final name = username.isNotEmpty ? username : email;

    return Text.rich(
      TextSpan(
        text: "welcome".tr(),
        children: [
          TextSpan(
            text: " $name",
            style: FontsUtils.mainStyle(
              color: stateColors.primary,
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
            hoverColor: stateColors.activity,
            iconData: UniconsLine.chart_pie,
            textTitle: "statistics".tr(),
            textSubtitle: "statistics_subtitle".tr(),
            onTap: () {
              context.beamToNamed(DashboardContentLocation.statisticsRoute);
            },
          ),
          SectionCard(
            hoverColor: stateColors.illustrations,
            iconData: UniconsLine.picture,
            textTitle: "illustrations".tr(),
            textSubtitle: "illustrations_subtitle".tr(),
            onTap: () {
              context.beamToNamed(DashboardContentLocation.illustrationsRoute);
            },
          ),
          SectionCard(
            hoverColor: stateColors.books,
            iconData: UniconsLine.book_alt,
            textTitle: "books".tr(),
            textSubtitle: "books_subtitle".tr(),
            onTap: () {
              context.beamToNamed(DashboardContentLocation.booksRoute);
            },
          ),
          SectionCard(
            hoverColor: stateColors.settings,
            iconData: UniconsLine.setting,
            textTitle: "settings".tr(),
            textSubtitle: "settings_subtitle".tr(),
            onTap: () {
              context.beamToNamed(DashboardContentLocation.settingsRoute);
            },
          ),
        ],
      ),
    );
  }
}