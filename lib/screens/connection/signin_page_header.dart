import 'package:artbooking/components/animations/fade_in_x.dart';
import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SigninPageHeader extends StatelessWidget {
  const SigninPageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FadeInX(
          beginX: 10.0,
          delay: Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.only(
              right: 20.0,
            ),
            child: IconButton(
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
                "signin".tr(),
                textAlign: TextAlign.center,
                style: Utilities.fonts.style(
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
                  "signin_existing_account".tr(),
                  overflow: TextOverflow.ellipsis,
                  style: Utilities.fonts.style(
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
