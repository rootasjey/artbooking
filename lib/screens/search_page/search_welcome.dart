import 'package:artbooking/components/texts/underlined_text.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SearchWelcome extends StatelessWidget {
  const SearchWelcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double fontSize = 32.0;
    final TextStyle emphaseStyle = Utilities.fonts.body4(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.0,
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: 0.8,
              child: Text.rich(
                TextSpan(
                  text: "search_hint_text_start".tr(),
                  children: [
                    WidgetSpan(
                      child: UnderlinedText(
                        underlinedColor:
                            Theme.of(context).primaryColor.withOpacity(0.6),
                        textValue: "illustrations".tr().toLowerCase(),
                        style: emphaseStyle,
                      ),
                    ),
                    TextSpan(text: "search_hint_text_comma".tr()),
                    WidgetSpan(
                      child: UnderlinedText(
                        underlinedColor: Theme.of(context)
                            .secondaryHeaderColor
                            .withOpacity(0.6),
                        textValue: "books".tr().toLowerCase(),
                        style: emphaseStyle,
                      ),
                    ),
                    TextSpan(text: "search_hint_text_or".tr()),
                    WidgetSpan(
                      child: UnderlinedText(
                        underlinedColor: Constants.colors.tertiary,
                        textValue: "users".tr().toLowerCase(),
                        style: emphaseStyle,
                      ),
                    ),
                    TextSpan(text: "search_hint_text_end".tr()),
                  ],
                  style: Utilities.fonts.body4(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),
            Lottie.asset(
              "assets/animations/search_box.json",
              width: 300.0,
              height: 300.0,
              repeat: true,
            ),
          ],
        ),
      ),
    );
  }
}
