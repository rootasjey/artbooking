import 'package:artbooking/components/animations/fade_in_x.dart';
import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ConnectionPageHeader extends StatelessWidget {
  const ConnectionPageHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    this.showBackButton = true,
  }) : super(key: key);

  /// Show back icon button if true.
  final bool showBackButton;

  /// Subtitle text value.
  final String subtitle;

  /// Title text value.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (showBackButton)
          FadeInX(
            beginX: 10.0,
            delay: Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.only(
                right: 20.0,
              ),
              child: IconButton(
                tooltip: "back".tr(),
                onPressed: () => Utilities.navigation.back(context),
                icon: Icon(UniconsLine.arrow_left),
              ),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FadeInY(
              beginY: 50.0,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Utilities.fonts.body(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FadeInY(
              delay: Duration(milliseconds: 50),
              beginY: 20.0,
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: Utilities.fonts.body(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
