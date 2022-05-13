import 'package:artbooking/components/arrow_divider.dart';
import 'package:artbooking/components/contact_form.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomePageContact extends StatefulWidget {
  @override
  _HomePageContactState createState() => _HomePageContactState();
}

class _HomePageContactState extends State<HomePageContact> {
  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = const EdgeInsets.only(
      top: 100.0,
      left: 120.0,
      right: 120.0,
    );

    if (Utilities.size.isMobileSize(context)) {
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
      style: Utilities.fonts.body(
        fontSize: 80.0,
        height: 0.9,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
