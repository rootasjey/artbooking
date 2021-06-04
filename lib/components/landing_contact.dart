import 'package:artbooking/components/arrow_divider.dart';
import 'package:artbooking/components/contact_form.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:artbooking/utils/constants.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:flutter/material.dart';

class LandingContact extends StatefulWidget {
  @override
  _LandingContactState createState() => _LandingContactState();
}

class _LandingContactState extends State<LandingContact> {
  @override
  Widget build(BuildContext context) {
    final viewWidth = MediaQuery.of(context).size.width;

    EdgeInsets padding = const EdgeInsets.only(
      top: 100.0,
      left: 120.0,
      right: 120.0,
    );

    if (viewWidth < Constants.maxMobileWidth) {
      padding = const EdgeInsets.only(
        top: 80.0,
        left: 20.0,
        right: 20.0,
      );
    }

    return Column(
      children: [
        ArrowDivider(),
        Padding(
          padding: padding,
          child: contactForm(),
        ),
      ],
    );
  }

  Widget contactForm() {
    return Column(
      children: [
        title(),
        ContactForm(),
      ],
    );
  }

  Widget title() {
    return Text(
      "contact_keep_touch".tr(),
      style: FontsUtils.mainStyle(
        fontSize: 80.0,
        height: 0.9,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
