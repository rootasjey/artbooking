import 'package:artbooking/components/arrow_divider.dart';
import 'package:artbooking/utils/constants.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingQuote extends StatefulWidget {
  const LandingQuote({Key? key}) : super(key: key);

  @override
  _LandingQuoteState createState() => _LandingQuoteState();
}

class _LandingQuoteState extends State<LandingQuote> {
  bool _isSmallView = false;

  @override
  Widget build(BuildContext context) {
    _isSmallView = false;

    final viewWidth = MediaQuery.of(context).size.width;

    EdgeInsets padding = const EdgeInsets.only(
      top: 100.0,
      left: 120.0,
      right: 120.0,
    );

    if (viewWidth < Constants.maxMobileWidth) {
      _isSmallView = true;

      padding = const EdgeInsets.only(
        top: 80.0,
        left: 20.0,
        right: 20.0,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ArrowDivider(),
        Padding(
          padding: padding,
          child: Column(
            children: [
              Text(
                "Your imagination"
                " is the only limit.",
                style: FontsUtils.mainStyle(
                  fontSize: _isSmallView ? 60.0 : 90.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              author(),
              viewMoreButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget author() {
    return Wrap(
      spacing: 12.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 50.0,
          child: Divider(
            thickness: 2.0,
          ),
        ),
        Opacity(
          opacity: 0.6,
          child: Text(
            "rootasjey",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget viewMoreButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: OutlinedButton(
        onPressed: () {
          launch("https://fig.style");
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 200.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "More quotes".toUpperCase(),
                  style: FontsUtils.mainStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(UniconsLine.arrow_right),
                ),
              ],
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          primary: Colors.pink,
        ),
      ),
    );
  }
}
