import 'package:artbooking/components/arrow_divider.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageQuote extends StatefulWidget {
  const HomePageQuote({Key? key}) : super(key: key);

  @override
  _HomePageQuoteState createState() => _HomePageQuoteState();
}

class _HomePageQuoteState extends State<HomePageQuote> {
  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    final double fontSize = isMobileSize ? 60.0 : 90.0;
    final EdgeInsets padding = isMobileSize
        ? const EdgeInsets.only(
            top: 80.0,
            left: 20.0,
            right: 20.0,
          )
        : const EdgeInsets.only(
            top: 100.0,
            left: 120.0,
            right: 120.0,
          );

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
                style: Utilities.fonts.style(
                  fontSize: fontSize,
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
                  style: Utilities.fonts.style(
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
