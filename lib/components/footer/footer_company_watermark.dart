import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class FooterCompanyWatermark extends StatelessWidget {
  const FooterCompanyWatermark({
    Key? key,
    this.padding = const EdgeInsets.only(
      left: 8.0,
      bottom: 8.0,
    ),
  }) : super(key: key);

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "artbooking 2021 - ${DateTime.now().year}",
              style: Utilities.fonts.style(
                fontWeight: FontWeight.w600,
              ),
            ),
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Opacity(
                  opacity: 0.6,
                  child: Icon(
                    UniconsLine.copyright,
                    size: 18.0,
                  ),
                ),
              ),
            ),
            TextSpan(
              text: "\n" + "company_by".tr(),
              style: Utilities.fonts.style2(),
            ),
            TextSpan(
              text: "\n\n" + "company_made_in".tr(),
              style: Utilities.fonts.style2(),
            ),
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(UniconsLine.heart, size: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
