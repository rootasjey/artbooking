import 'package:animations/animations.dart';
import 'package:artbooking/screens/about/about_page_credit_item.dart';
import 'package:artbooking/components/footer/footer.dart';
import 'package:artbooking/components/hero_image.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supercharged/supercharged.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool isFabVisible = false;

  final captionOpacity = 0.6;

  final maxWidth = 600.0;

  final _pageScrollController = ScrollController();

  final paragraphOpacity = 0.6;
  final paragraphStyle = TextStyle(
    fontSize: 18.0,
    height: 1.5,
  );

  final titleOpacity = 0.9;
  final titleStyle = Utilities.fonts.style(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
              onPressed: () {
                _pageScrollController.animateTo(
                  0.0,
                  duration: 500.milliseconds,
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              child: Icon(Icons.arrow_upward),
            )
          : null,
      body: Overlay(
        initialEntries: [
          OverlayEntry(builder: (context) {
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollNotif) {
                // FAB visibility
                if (scrollNotif.metrics.pixels < 50 && isFabVisible) {
                  setState(() => isFabVisible = false);
                } else if (scrollNotif.metrics.pixels > 50 && !isFabVisible) {
                  setState(() => isFabVisible = true);
                }

                return false;
              },
              child: CustomScrollView(
                controller: _pageScrollController,
                slivers: <Widget>[
                  ApplicationBar(),
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      bottom: 200.0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Column(
                          children: <Widget>[
                            appIconImage(),
                            otherLinks(),
                            whatIs(),
                            features(),
                            whoIs(),
                            creditsSection(),
                          ],
                        ),
                      ]),
                    ),
                  ),
                  if (kIsWeb && MediaQuery.of(context).size.width > 700.0)
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Footer(),
                      ]),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget appIconImage() {
    final size = Utilities.size.isMobileSize(context) ? 280.0 : 380.0;

    return Container(
      padding: const EdgeInsets.only(
        bottom: 40.0,
      ),
      width: maxWidth,
      child: Column(
        children: [
          Center(
            child: OpenContainer(
              closedColor: Colors.transparent,
              closedElevation: 0.0,
              closedBuilder: (context, openContainer) {
                return Container(
                  width: size,
                  height: size,
                  child: Ink.image(
                    height: size,
                    width: size,
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/app_icon/512.png'),
                    child: InkWell(
                      onTap: openContainer,
                    ),
                  ),
                );
              },
              openBuilder: (context, callback) {
                return HeroImage(
                  imageProvider: AssetImage('assets/images/app_icon/512.png'),
                );
              },
            ),
          ),
          Center(
            child: TextButton(
              onPressed: null,
              child: Opacity(
                opacity: captionOpacity,
                child: Text('ArtBooking'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget features() {
    return SizedBox(
      width: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 120.0),
            child: Opacity(
              opacity: titleOpacity,
              child: Text(
                'features'.tr().toUpperCase(),
                style: titleStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Wrap(
              spacing: 10.0,
              children: [
                Icon(
                  UniconsLine.exclamation_circle,
                  color: Colors.lightGreen,
                ),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    'available_now'.tr(),
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Opacity(
              opacity: paragraphOpacity,
              child: Text(
                'features_list'.tr(),
                style: paragraphStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: Wrap(
              spacing: 10.0,
              children: [
                Icon(
                  UniconsLine.rocket,
                  color: Colors.yellow.shade600,
                ),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    'future_dev'.tr(),
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                'future_dev_list'.tr(),
                style: paragraphStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget creditsSection() {
    final Color baseColor =
        Theme.of(context).textTheme.bodyText1?.color?.withOpacity(0.6) ??
            Colors.white;

    return SizedBox(
      width: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(
            opacity: titleOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 120.0, bottom: 30.0),
              child: Text(
                'credits'.tr().toUpperCase(),
                style: titleStyle,
              ),
            ),
          ),
          AboutPageCreditItem(
            textValue: 'icons_by'.tr(args: [' Unicons']),
            onTap: () => launch('https://iconscout.com/unicons'),
            iconData: UniconsLine.palette,
            hoverColor: Theme.of(context).primaryColor,
            baseColor: baseColor,
          ),
          AboutPageCreditItem(
            textValue: 'illustration_by_from'.tr(
              args: ['Natasha Remarchuk', 'Icons8'],
            ),
            onTap: () => launch('https://icons8.com/'),
            iconData: UniconsLine.image,
            hoverColor: Colors.pink,
            baseColor: baseColor,
          ),
          AboutPageCreditItem(
            textValue: 'app_screenshot_credits'.tr(args: ['AppMockUp']),
            onTap: () => launch('https://app-mockup.com/'),
            iconData: UniconsLine.mobile_android,
            hoverColor: Theme.of(context).secondaryHeaderColor,
            baseColor: baseColor,
          ),
        ],
      ),
    );
  }

  Widget otherLinks() {
    return SizedBox(
      width: maxWidth / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Opacity(
              opacity: 0.7,
              child: Text(
                Constants.appVersion,
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('changelog'.tr()),
              trailing: Icon(Icons.arrow_forward),
              // onTap: () => context.router.push(ChangelogPageRoute()),
              onTap: () => context.beamBack(),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('tos'.tr()),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => context.beamBack(),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('GitHub'),
              trailing: Icon(Icons.open_in_new),
              onTap: () => launch(Constants.links.githubLink),
            ),
          ),
        ],
      ),
    );
  }

  Widget whatIs() {
    return Container(
      width: maxWidth,
      padding: const EdgeInsets.only(
        top: 40.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Opacity(
              opacity: titleOpacity,
              child: Text(
                'the_concept'.tr().toUpperCase(),
                style: titleStyle,
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Text(
                'the_concept_content'.tr(),
                style: paragraphStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget whoIs() {
    return SizedBox(
      width: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(
            opacity: titleOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: Text(
                'the_author'.tr().toUpperCase(),
                style: titleStyle,
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                "about_me_1".tr(),
                style: paragraphStyle,
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "about_me_2".tr(),
                style: paragraphStyle,
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "about_me_3".tr(),
                style: paragraphStyle,
              ),
            ),
          ),
          Opacity(
            opacity: titleOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: Text("the_story".tr().toUpperCase(), style: titleStyle),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "the_story_content_1".tr(),
                style: paragraphStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Opacity(
              opacity: paragraphOpacity,
              child: Text(
                "the_story_content_2".tr(),
                style: paragraphStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 20.0,
            ),
            child: Opacity(
              opacity: paragraphOpacity,
              child: Text(
                "the_story_content_3".tr(),
                style: paragraphStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
