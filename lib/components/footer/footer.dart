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
  final ScrollController? pageScrollController;
  final bool closeModalOnNav;
  final bool autoNavToHome;

  Footer({
    this.autoNavToHome = true,
    this.pageScrollController,
    this.closeModalOnNav = false,
  });

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends ConsumerState<Footer> {
  @override
  Widget build(BuildContext context) {
    double horizontal = 60.0;
    WrapAlignment alignment = WrapAlignment.spaceAround;

    if (Utilities.size.isMobileSize(context)) {
      horizontal = 12.0;
      alignment = WrapAlignment.spaceBetween;
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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 60.0),
            child: Wrap(
              runSpacing: 80.0,
              spacing: 54.0,
              alignment: alignment,
              children: <Widget>[
                FooterLegal(),
                FooterArtworks(),
                FooterUser(),
                FooterAboutUs(),
              ],
            ),
          ),
          Wrap(
            spacing: 24.0,
            children: [
              socialIcon(
                onTap: () => launch("https://twitter/artbooking"),
                iconData: UniconsLine.twitter,
              ),
              socialIcon(
                onTap: () => launch("https://facebook/artbooking"),
                iconData: UniconsLine.facebook_f,
              ),
              socialIcon(
                onTap: () => launch("https://instagram/artbooking"),
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

  Widget socialIcon({Function()? onTap, required IconData iconData}) {
    return CircleButton(
      onTap: onTap,
      backgroundColor: Colors.black87,
      icon: Icon(iconData, color: Colors.white),
    );
  }
}
