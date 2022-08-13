import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SignupPageLoading extends StatelessWidget {
  const SignupPageLoading({
    Key? key,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: isMobileSize
            ? const EdgeInsets.only(top: 0.0, bottom: 150.0)
            : const EdgeInsets.only(top: 100.0, bottom: 300.0),
        child: Column(
          children: [
            AnimatedAppIcon(
              textTitle: "account_creating".tr() + "...",
            ),
            Opacity(
              opacity: 0.8,
              child: AnimatedTextKit(
                animatedTexts: [
                  animatedText("account_creating_subtitle.glad".tr()),
                  animatedText("account_creating_subtitle.draw".tr()),
                  animatedText("account_creating_subtitle.atelier".tr()),
                  animatedText("account_creating_subtitle.settings".tr()),
                  animatedText("account_creating_subtitle.duration".tr()),
                  animatedText("account_creating_subtitle.check".tr()),
                  animatedText("account_creating_subtitle.profile_page".tr()),
                  animatedText("account_creating_subtitle.masterpiece".tr()),
                ],
                isRepeatingAnimation: true,
                repeatForever: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  RotateAnimatedText animatedText(String text) {
    return RotateAnimatedText(
      text,
      duration: Duration(seconds: 5),
      textStyle: Utilities.fonts.body(
        fontSize: 14.0,
        fontWeight: FontWeight.w700,
        height: 2,
        decoration: TextDecoration.underline,
        decorationColor: Colors.amber,
        decorationThickness: 2.0,
        decorationStyle: TextDecorationStyle.wavy,
      ),
    );
  }
}
