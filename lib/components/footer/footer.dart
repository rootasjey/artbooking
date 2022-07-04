import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/components/footer/footer_company_watermark.dart';
import 'package:artbooking/components/footer/sections/footer_about_us.dart';
import 'package:artbooking/components/footer/sections/footer_artworks.dart';
import 'package:artbooking/components/footer/sections/footer_legal.dart';
import 'package:artbooking/components/footer/sections/footer_user.dart';
import 'package:artbooking/components/icons/app_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends ConsumerStatefulWidget {
  Footer({
    this.autoNavToHome = true,
    this.pageScrollController,
    this.closeModalOnNav = false,
  });

  final ScrollController? pageScrollController;
  final bool closeModalOnNav;
  final bool autoNavToHome;

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends ConsumerState<Footer> {
  @override
  Widget build(BuildContext context) {
    double horizontal = 60.0;

    final bool isMobileSize = Utilities.size.isMobileSize(context);

    if (isMobileSize) {
      horizontal = 12.0;
    }

    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: 90.0,
      ),
      child: Column(
        children: [
          AppIcon(size: 30.0),
          sectionsWidget(isMobileSize),
          Wrap(
            spacing: 24.0,
            children: [
              socialIcon(
                onTap: () => launchUrl(Uri.parse("https://twitter/artbooking")),
                iconData: UniconsLine.twitter,
              ),
              socialIcon(
                onTap: () =>
                    launchUrl(Uri.parse("https://facebook/artbooking")),
                iconData: UniconsLine.facebook_f,
              ),
              socialIcon(
                onTap: () =>
                    launchUrl(Uri.parse("https://instagram/artbooking")),
                iconData: UniconsLine.instagram,
              ),
            ],
          ),
          FooterCompanyWatermark(
            padding: const EdgeInsets.only(top: 12.0),
          ),
        ],
      ),
    );
  }

  Widget sectionsWidget(bool isMobileSize) {
    final WrapAlignment alignment =
        isMobileSize ? WrapAlignment.spaceBetween : WrapAlignment.spaceAround;

    if (isMobileSize) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Wrap(
          runSpacing: 12.0,
          spacing: 12.0,
          alignment: alignment,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: <Widget>[
            FooterLegal(),
            FooterArtworks(),
            FooterUser(),
            FooterAboutUs(),
          ]
              .map(
                (Widget child) => SizedBox(
                  width: 180.0,
                  child: child,
                ),
              )
              .toList(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0),
      child: Wrap(
        runSpacing: 80.0,
        spacing: 54.0,
        alignment: alignment,
        children: <Widget>[
          FooterLegal(useCard: true),
          FooterArtworks(),
          FooterUser(),
          FooterAboutUs(),
        ],
      ),
    );
  }

  Widget socialIcon({Function()? onTap, required IconData iconData}) {
    return CircleButton(
      onTap: onTap,
      backgroundColor: Colors.black87,
      icon: Icon(iconData, color: Colors.white),
    );
  }
}
